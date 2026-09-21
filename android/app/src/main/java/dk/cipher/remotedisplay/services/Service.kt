package dk.cipher.remotedisplay.services

import dk.cipher.remotedisplay.utils.Error
import dk.cipher.remotedisplay.R

object Services {
    sealed interface Status {
        object Unavailable: Status
        object Searching: Status
        object Available: Status
        object Connecting: Status
        object Connected: Status
        object Disconnecting: Status
        object Disconnected: Status
        data class Failure(val error: kotlin.Error): Status
    }

    interface Service {
        val status: Status
        suspend fun search()
        suspend fun connect()
        suspend fun disconnect()
    }

    interface ServiceDelegate {
        fun serviceDidUpdateStatus(service: Service)
    }
    class NoBuiltInServiceError: Error(R.string.error_description_no_built_in)
    class ChangeServiceWhileConnectedError: Error(R.string.error_description_change_while_connected)
    class ServiceControllerNotInitialisedError: Error(R.string.error_description_service_controller_not_initialized)
}