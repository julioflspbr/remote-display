package dk.cipher.remotedisplay.services

import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.getSystemService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.launch
import androidx.core.content.edit
import kotlinx.coroutines.coroutineScope

class ServiceController(dependencies: Dependencies) {
    val builtIn: List<Services.Service>
    var autoConnect: Boolean
        get() = _autoConnect
        set(value) {
            _autoConnect = value
            this.storage?.edit {
                putBoolean(AUTO_CONNECT_STORAGE_KEY, value)
            }
        }

    var status: Services.Status = Services.Status.Unavailable
        private set

    private val storage: SharedPreferences?
    private var connectedIndex = 0
    private var _autoConnect: Boolean

    init {
        this.builtIn = dependencies.builtInServices
        if (this.builtIn.isEmpty()) {
            throw Services.NoBuiltInServiceError()
        }
        this.storage = dependencies.context.getSystemService<SharedPreferences>()
        if (dependencies.autoConnect != null) {
            _autoConnect = dependencies.autoConnect
        } else {
            _autoConnect = this.storage?.getBoolean(AUTO_CONNECT_STORAGE_KEY, false) ?: false
        }

        if (this.autoConnect) {
            dependencies.task {
                val services = this.search()
                val firstServiceAvailable = services.firstAvailable()
                if (firstServiceAvailable != null) {
                    firstServiceAvailable.connect()
                }
            }
        }
    }

    fun search(): Channel<Services.Service> {
        val channel = Channel<Services.Service>()
        CoroutineScope(SupervisorJob()).launch {
            coroutineScope {
                for (service in builtIn) {
                    launch(Dispatchers.IO) {
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
        return this.builtIn[this.connectedIndex]
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

    data class Dependencies(
        val builtInServices: List<Services.Service>,
        val context: Context,
        val task: ConcurrencyContext,
        val autoConnect: Boolean?
    ) {
        typealias ConcurrencyContext = (suspend () -> Unit) -> Unit

        companion object {
            fun live(context: Context) = Dependencies(
                builtInServices = listOf(
//                    ServiceSimulator("Simulated Service LALA", context),
//                    ServiceSimulator("Simulated Service LONES", context)
                ),
                context = context,
                task = { operation ->
                    CoroutineScope(Dispatchers.Main).launch {
                        operation()
                    }
                },
                autoConnect = null
            )
        }
    }

    companion object {
        const val AUTO_CONNECT_STORAGE_KEY = "services.simulator.autoConnect"
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