package remote.work

class RemoteWorkRequest {
    String ownerUsername
    String scriptName
    String jobType
    String status = 'UPLOADED'
    String originalFilename
    String inputPath
    String resultPath
    String workerJobId
    String configJson = '{}'
    String errorMessage
    Date dateCreated
    Date lastUpdated

    static constraints = {
        ownerUsername blank: false
        scriptName blank: false
        jobType blank: false
        originalFilename blank: false
        inputPath blank: false
        resultPath nullable: true
        workerJobId nullable: true
        errorMessage nullable: true, maxSize: 8192
        configJson maxSize: 65535
    }
    static mapping = {
        table 'remote_work_request'
        configJson type: 'text'
        errorMessage type: 'text'
    }
}
