package remote.work

import java.util.zip.ZipFile
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.StandardCopyOption

class RemoteWorkPackageService {
    def grailsApplication

    File getRootDirectory() {
        String base = System.getenv('REMOTE_WORK_STORAGE') ?: '/jobs/remote-work'
        File dir = new File(base).canonicalFile
        if (!dir.exists() && !dir.mkdirs()) throw new IOException("Cannot create storage: ${dir}")
        dir
    }

    long getMaxBytes() {
        String value = System.getenv('MAX_UPLOAD_SIZE') ?: '1073741824'
        Long.parseLong(value)
    }

    List<String> inspectZip(File file) {
        long expanded = 0L
        List<String> names = []
        new ZipFile(file).withCloseable { zip ->
            def entries = zip.entries()
            int count = 0
            while (entries.hasMoreElements()) {
                def entry = entries.nextElement()
                if (++count > 10000) throw new IllegalArgumentException('Too many ZIP entries')
                String name = entry.name.replace('\\', '/')
                if (name.startsWith('/') || name == '..' || name.contains('../') ||
                    name.matches('(?i)^[a-z]:.*')) {
                    throw new IllegalArgumentException('Unsafe ZIP entry')
                }
                if (entry.size > getMaxBytes()) throw new IllegalArgumentException('ZIP entry too large')
                if (entry.size >= 0) expanded += entry.size
                if (expanded > getMaxBytes() * 4L) throw new IllegalArgumentException('Expanded ZIP too large')
                if (!entry.directory) names << name
            }
        }
        names
    }

    File storeInput(def multipart, Long requestId) {
        if (!multipart || multipart.empty) throw new IllegalArgumentException('ZIP file required')
        String original = multipart.originalFilename ?: ''
        if (!original.toLowerCase(Locale.ROOT).endsWith('.zip'))
            throw new IllegalArgumentException('Only ZIP packages are accepted')
        File dir = new File(rootDirectory, requestId.toString())
        if (!dir.mkdirs() && !dir.isDirectory()) throw new IOException('Cannot create job directory')
        File target = new File(dir, 'input.zip')
        try {
            multipart.transferTo(target)
            if (target.length() > maxBytes) throw new IllegalArgumentException('ZIP exceeds server upload limit')
            inspectZip(target)
            return target
        } catch (Exception e) {
            target.delete()
            throw e
        }
    }
}
