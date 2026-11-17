package remote.work

import jakarta.annotation.PostConstruct
import org.codehaus.groovy.runtime.MethodClosure
import taack.app.TaackApp
import taack.app.TaackAppRegisterService

/** Register Remote Work Manager in the global left application menu. */
class RemoteWorkRegistrationService {
    static lazyInit = false

    @PostConstruct
    void init() {
        def stream = this.class.getResourceAsStream('/remote/work/remote-work.svg')
        if (!stream) {
            log.error('REMOTE WORK: menu icon missing')
            return
        }
        String svg = stream.withCloseable { new String(it.readAllBytes(), 'UTF-8') }
        TaackAppRegisterService.register(new TaackApp(RemoteWorkController.&index as MethodClosure, svg))
        log.info('REMOTE WORK: registered in application menu')
    }
}
