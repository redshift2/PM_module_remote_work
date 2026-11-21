package remote.work

import grails.plugin.springsecurity.annotation.Secured
import groovy.json.JsonSlurper
import serveradmin.ServerJob
import serveradmin.WorkerScript
import serveradmin.ServerJobService
import serveradmin.ServerJobPackageService
import java.nio.file.Files
import java.nio.file.Paths

@Secured(['ROLE_ADMIN', 'ROLE_CREATE_REMOTE_WORK'])
class RemoteWorkController {
    def springSecurityService
    ServerJobService serverJobService
    ServerJobPackageService serverJobPackageService

    private String username() { springSecurityService.currentUser?.username?.toString() }
    private boolean isAdmin() {
        springSecurityService.authentication?.authorities?.any { it.authority == 'ROLE_ADMIN' }
    }
    private ServerJob owned(Long id) {
        ServerJob job = ServerJob.get(id)
        if (!job || job.routeData != 'JOB_RESULTS' ||
            !(job.parametersJson ?: '').contains('"remoteWork":true') ||
            (!isAdmin() && job.submittedBy != username())) return null
        job
    }

    def index() {
        String tab = params.tab in ['jobs', 'results'] ? params.tab.toString() : 'jobs'
        def jobs = ServerJob.list(sort:'dateCreated', order:'desc', max:200).findAll {
            it.routeData == 'JOB_RESULTS' &&
            (it.parametersJson ?: '').contains('"remoteWork":true') &&
            (isAdmin() || it.submittedBy == username())
        }
        Map descriptions = [:]
        jobs.each { ServerJob j ->
            try { descriptions[j.id] = (new JsonSlurper().parseText(j.parametersJson ?: '{}') as Map).jobDescription ?: '' }
            catch (Exception ignored) { descriptions[j.id] = '' }
        }
        [jobs:jobs, descriptions:descriptions, tab:tab, scripts:WorkerScript.findAllByJobTypeAndEnabled('CAD_REMOTE_JOB', true, [sort:'name']),
         maxUploadBytes: System.getenv('MAX_UPLOAD_SIZE') ?: '1073741824']
    }

    def schema(Long id) {
        WorkerScript script = WorkerScript.get(id)
        if (!script?.enabled || script.jobType != 'CAD_REMOTE_JOB') { response.sendError(404); return }
        Map schema = new JsonSlurper().parseText(script.configurationSchemaJson ?: '{"fields":[]}') as Map
        render(contentType:'application/json', text:groovy.json.JsonOutput.toJson(schema))
    }

    private Map parseOptions(WorkerScript script, def upload) {
        Map schema = new JsonSlurper().parseText(script.configurationSchemaJson ?: '{"fields":[]}') as Map
        Map options = [:]
        (schema.fields ?: []).each { Map field ->
            String name = field.name.toString()
            String type = field.type.toString()
            String raw = params.get('option_' + name)?.toString()?.trim() ?: ''
            if (!raw && type != 'boolean' && field.containsKey('default') && field.default != null) raw = field.default.toString()
            if (field.required && !raw) throw new IllegalArgumentException(name + ' is required')
            if (raw.length() > 512) throw new IllegalArgumentException(name + ' is too long')
            if (type == 'integer' && raw && !(raw ==~ /-?[0-9]{1,12}/))
                throw new IllegalArgumentException(name + ' must be an integer')
            if (type == 'select' && raw && !(raw in field.options))
                throw new IllegalArgumentException(name + ' has an invalid selection')
            if (type == 'boolean') raw = (raw == 'true') ? 'true' : 'false'
            if (type == 'zipFile' && raw && (raw.startsWith('/') || raw.contains('\\') ||
                raw.split('/').contains('..')))
                throw new IllegalArgumentException(name + ' is not a safe ZIP filename')
            options[name] = type == 'integer' && raw ? Long.parseLong(raw) :
                type == 'boolean' ? raw == 'true' : raw
        }
        return options
    }

    def submit() {
        if (request.method != 'POST') { response.sendError(405); return }
        ServerJob job = null
        try {
            Long scriptId = params.long('scriptId')
            WorkerScript script = scriptId == null ? null : WorkerScript.get(scriptId)
            if (!script?.enabled || script.jobType != 'CAD_REMOTE_JOB') throw new IllegalArgumentException('Choose an enabled CAD_REMOTE_JOB script')
            def upload = request.getFile('package')
            if (!upload || upload.empty) throw new IllegalArgumentException('ZIP required')
            long maxBytes = Long.parseLong(System.getenv('MAX_UPLOAD_SIZE') ?: '1073741824')
            if (upload.size > maxBytes) throw new IllegalArgumentException('Upload exceeds server limit')
            String prefix = (params.outputPrefix ?: '').toString().trim()
            String inputFile = (params.inputFile ?: '').toString().trim()
            if (prefix && !prefix.matches('[A-Za-z0-9_.-]{1,100}'))
                throw new IllegalArgumentException('Invalid output prefix')
            if (inputFile && (inputFile.startsWith('/') || inputFile.contains('\\\\') ||
                inputFile.split('/').contains('..')))
                throw new IllegalArgumentException('Invalid input filename')
            String description = (params.jobDescription ?: '').toString().trim()
            if (description.length() > 500) throw new IllegalArgumentException('Job description must be 500 characters or fewer')
            Map config = [remoteWork:true, scriptId:script.id, jobDescription:description,
                          scriptOptions:parseOptions(script, upload),
                          inputFile:inputFile, outputPrefix:prefix]
            job = serverJobService.submit(script.jobType, username(), config, 'JOB_RESULTS')
            String filename = serverJobPackageService.store(upload, job.id as Long, config)
            serverJobService.setPackageFileName(job.id as Long, filename)
            flash.message = 'Job queued: ' + job.id
        } catch (Exception ex) {
            if (job?.id) {
                try { serverJobService.deleteJob(job.id as Long) } catch(Exception ignored) {}
            }
            flash.error = ex.message
        }
        response.sendRedirect('/remoteWork/index')
        return
    }

    def download(Long id) {
        ServerJob job = owned(id)
        if (!job) { response.sendError(404); return }
        if (job.status != 'COMPLETED' || !job.resultFileName) { response.sendError(409); return }
        String base = System.getenv('SERVER_ADMIN_JOB_STORAGE')
        if (!base) { response.sendError(404); return }
        def root = Paths.get(base).toRealPath()
        def path = root.resolve(job.resultFileName).normalize()
        if (!path.startsWith(root) || !Files.isRegularFile(path) ||
            !path.toRealPath().startsWith(root)) { response.sendError(404); return }
        response.contentType = 'application/zip'
        response.setHeader('Content-Disposition', 'attachment; filename="remote-work-' + job.id + '.zip"')
        Files.copy(path, response.outputStream)
    }

    def deleteResult(Long id) {
        if (request.method != 'POST') { response.sendError(405); return }
        ServerJob job = owned(id)
        if (!job) { response.sendError(404); return }
        if (job.status != 'COMPLETED') { response.sendError(409); return }
        try {
            serverJobService.deleteJob(job.id as Long)
            flash.message = 'Result removed from the list'
        } catch (Exception ex) { flash.error = ex.message }
        response.sendRedirect('/remoteWork/index?tab=results')
        return
    }

    def clearInactive() {
        if (request.method != 'POST') { response.sendError(405); return }
        int count = 0
        // Never clear queued, running, uploading, or completed result jobs.
        def candidates = ServerJob.list(sort:'dateCreated', order:'desc', max:1000).findAll {
            it.status in ['FAILED', 'CANCELLED'] &&
            it.routeData == 'JOB_RESULTS' &&
            (it.parametersJson ?: '').contains('"remoteWork":true') &&
            (isAdmin() || it.submittedBy == username())
        }
        candidates.each { ServerJob job ->
            try { serverJobService.deleteJob(job.id as Long); count++ }
            catch (Exception ignored) { /* Another request may have changed this job. */ }
        }
        flash.message = count + ' inactive job(s) cleared'
        response.sendRedirect('/remoteWork/index?tab=jobs')
        return
    }

    def cancel(Long id) {
        if (request.method != 'POST') { response.sendError(405); return }
        ServerJob job = owned(id)
        if (!job) { response.sendError(404); return }
        try { serverJobService.cancelJob(job.id as Long); flash.message = 'Job cancelled' }
        catch(Exception ex) { flash.error = ex.message }
        response.sendRedirect('/remoteWork/index')
        return
    }
}
