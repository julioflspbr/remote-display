package dk.cipher.remotedisplay.services

import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.getSystemService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.launch
import androidx.core.content.edit
import dk.cipher.remotedisplay.App
import kotlinx.coroutines.coroutineScope
import kotlin.coroutines.CoroutineContext

class ServiceController(private val dependencies: Dependencies) {
    val builtIn = this.dependencies.builtInServices
    var autoConnect: Boolean
        get() = _autoConnect
        set(value) {
            _autoConnect = value
            this.dependencies.storage?.edit {
                putBoolean(AUTO_CONNECT_STORAGE_KEY, value)
            }
        }
    var status: Services.Status = Services.Status.Unavailable
        private set
    private var connectedIndex = 0
    private var _autoConnect: Boolean

    init {
        if (this.builtIn.isEmpty()) {
            this.dependencies.noServicesErrorHandler()
        }
        _autoConnect = if (this.dependencies.autoConnect != null) {
            this.dependencies.autoConnect
        } else {
            this.dependencies.storage?.getBoolean(AUTO_CONNECT_STORAGE_KEY, false) ?: false
        }
    }

    suspend fun autoConnect(searchContext: CoroutineContext? = null) {
        if (!this.autoConnect) {
            return
        }
        val services = this.search(searchContext)
        val firstAvailable = services.firstAvailable()
        firstAvailable?.connect()
    }

    fun search(context: CoroutineContext? = null): Channel<Services.Service> {
        val channel = Channel<Services.Service>()
        CoroutineScope((context ?: Dispatchers.Default) + SupervisorJob()).launch {
            coroutineScope {
                for (service in builtIn) {
                    launch(context ?: Dispatchers.IO) {
                        service.search()
                        channel.send(service)

                        if (service.status == Services.Status.Available) {
                            status = Services.Status.Available
                        }
                    }
                }
            }
            if (status != Services.Status.Available) {
                status = Services.Status.Unavailable
            }
            channel.close()
        }
        return channel
    }

    suspend fun connect() {
        this.status = Services.Status.Connecting
        this.builtIn[this.connectedIndex].connect()
        this.status = Services.Status.Connected
    }

    fun selectFirstService(): Services.Service {
        if (this.status == Services.Status.Connecting || this.status == Services.Status.Connected) {
            throw Services.ChangeServiceWhileConnectedError()
        }
        this.connectedIndex = 0
        return this.builtIn[0]
    }

    fun selectNextService(): Services.Service? {
        if (this.status == Services.Status.Connecting || this.status == Services.Status.Connected) {
            throw Services.ChangeServiceWhileConnectedError()
        }
        if (this.connectedIndex >= this.builtIn.size - 1) {
            return null
        }
        this.connectedIndex += 1
        return this.builtIn[this.connectedIndex]
    }

    suspend fun disconnect() {
        this.status = Services.Status.Disconnecting
        this.builtIn[this.connectedIndex].disconnect()
        this.status = Services.Status.Disconnected
    }

    fun setDelegate(delegate: Services.ServiceDelegate) {
        for (service in this.builtIn) {
            service.setDelegate(delegate)
        }
    }

    data class Dependencies(
        val storage: SharedPreferences?,
        val builtInServices: List<Services.Service>,
        val autoConnect: Boolean?,
        val noServicesErrorHandler: () -> Unit
    ) {
        companion object {
            fun live(): Dependencies {
                val storage = App.shared.getSystemService<SharedPreferences>()
                return Dependencies(
                    storage = storage,
                    builtInServices = listOf(
                        SmokeService("Simulated Service LALA", storage),
                        SmokeService("Simulated Service LONES", storage)
                    ),
                    autoConnect = null,
                    noServicesErrorHandler = {
                        error("Please inform at least one display service to send messages to.")
                    }
                )
            }
        }
    }

    companion object {
        private const val AUTO_CONNECT_STORAGE_KEY = "services.simulator.autoConnect"
    }
}

suspend fun Channel<Services.Service>.firstAvailable(): Services.Service? {
    val iterator = this.iterator()
    while (iterator.hasNext()) {
        val service = iterator.next()
        if (service.status == Services.Status.Available) {
            return service
        }
    }
    return null
}