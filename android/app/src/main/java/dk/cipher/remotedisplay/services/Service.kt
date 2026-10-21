package dk.cipher.remotedisplay.services

import androidx.annotation.StringRes
import dk.cipher.remotedisplay.utils.LocalisedError
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
        data class Failure(val error: Throwable): Status
    }

    interface Service {
        val status: Status
        suspend fun search()
        suspend fun connect()
        suspend fun disconnect()
        fun setDelegate(delegate: ServiceDelegate)
    }

    interface ServiceDelegate {
        fun serviceDidUpdateStatus(service: Service)
    }
    class ChangeServiceWhileConnectedError: LocalisedError(
        errorDescription = R.string.error_description_change_while_connected,
        recoverySuggestion =  R.string.error_recovery_suggestion_change_while_connected
    )
}