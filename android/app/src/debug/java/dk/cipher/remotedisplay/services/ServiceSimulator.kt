package dk.cipher.remotedisplay.services

import android.content.Context
import android.content.SharedPreferences
import androidx.annotation.StringRes
import androidx.core.content.edit
import androidx.core.content.getSystemService
import dk.cipher.remotedisplay.R
import dk.cipher.remotedisplay.utils.Error
import kotlinx.coroutines.TimeoutCancellationException
import kotlinx.coroutines.delay
import kotlinx.coroutines.withTimeout
import kotlin.random.Random
import kotlin.random.nextInt
import kotlin.time.Duration.Companion.seconds

class ServiceSimulator(val name: String, context: Context): Services.Service {
    var delegate: Services.ServiceDelegate? = null

    private val storage: SharedPreferences?
    private var _simulateSearchFailure: Boolean
    var simulateSearchFailure: Boolean
        get() = _simulateSearchFailure
        set(value) {
            _simulateSearchFailure = value
            this.storage?.edit {
                putBoolean(FAIL_SEARCH_STORAGE_KEY, value)
            }
        }

    private var _simulateConnectionFailure: Boolean
    var simulateConnectionFailure: Boolean
        get() = _simulateConnectionFailure
        set(value) {
            _simulateConnectionFailure = value
            this.storage?.edit {
                putBoolean(FAIL_CONNECTION_STORAGE_KEY, value)
            }
        }

    private var _simulateDisconnectionFailure: Boolean
    var simulateDisconnectionFailure: Boolean
        get() = _simulateDisconnectionFailure
        set(value) {
            _simulateDisconnectionFailure = value
            this.storage?.edit {
                putBoolean(FAIL_DISCONNECTION_STORAGE_KEY, value)
            }
        }

    private var _status: Services.Status = Services.Status.Unavailable
    override var status: Services.Status
        get() = _status
        set(value) {
            _status = value
            this.delegate?.serviceDidUpdateStatus(this)
        }

    init {
        this.storage = context.getSystemService<SharedPreferences>()
        _simulateSearchFailure = this.storage?.getBoolean(FAIL_SEARCH_STORAGE_KEY, false) ?: false
        _simulateConnectionFailure = this.storage?.getBoolean(FAIL_CONNECTION_STORAGE_KEY, false) ?: false
        _simulateDisconnectionFailure = this.storage?.getBoolean(FAIL_DISCONNECTION_STORAGE_KEY, false) ?: false
    }

    override suspend fun search() {
        if (this.status != Services.Status.Unavailable) {
            return
        }
        try {
            this.status = Services.Status.Searching
            withTimeout(TIMEOUT_LIMIT.seconds) {
                simulateWork()
                if (simulateSearchFailure) {
                    throw SimulationError(R.string.error_description_search_simulation)
                }
            }
            this.status = Services.Status.Available
        } catch (_: TimeoutCancellationException) {
            this.status = Services.Status.Unavailable
        } catch(error: kotlin.Error) {
            this.status = Services.Status.Failure(error)
        }
    }

    override suspend fun connect() {
        if (this.status == Services.Status.Unavailable) {
            this.search()
        }
        if (this.status != Services.Status.Available) {
            return
        }
        try {
            this.status = Services.Status.Connecting
            withTimeout(TIMEOUT_LIMIT.seconds) {
                simulateWork()
                if (simulateConnectionFailure) {
                    throw SimulationError(R.string.error_description_connection_simulation)
                }
            }
            this.status = Services.Status.Connected
        } catch(error: kotlin.Error) {
            this.status = Services.Status.Failure(error)
            throw error
        }
    }

    override suspend fun disconnect() {
        if (this.status != Services.Status.Connected) {
            return
        }
        try {
            this.status = Services.Status.Disconnecting
            withTimeout(TIMEOUT_LIMIT.seconds) {
                simulateWork()
                if (simulateDisconnectionFailure) {
                    throw SimulationError(R.string.error_description_disconnection_simulation)
                }
            }
            this.status = Services.Status.Disconnected
        } catch (error: kotlin.Error) {
            this.status = Services.Status.Failure(error)
            throw error
        }
    }

    private suspend fun simulateWork() {
        val workPeriod = Random.nextInt(IntRange(0, MAX_CONNECTION_TIMEOUT)).seconds
        delay(duration = workPeriod)
    }

    companion object {
        const val FAIL_SEARCH_STORAGE_KEY = "services.simulator.failSearch"
        const val FAIL_CONNECTION_STORAGE_KEY = "services.simulator.failConnection"
        const val FAIL_DISCONNECTION_STORAGE_KEY = "services.simulator.failDisconnection"

        private const val MAX_CONNECTION_TIMEOUT = 5 // secs
        private const val TIMEOUT_LIMIT = 4 // secs; smaller than max to simulate timeout
    }

    class SimulationError(@StringRes messageStringResource: Int): Error(messageStringResource)
}