package dk.cipher.remotedisplay.alert

import dk.cipher.remotedisplay.utils.ClosingChannel
import dk.cipher.remotedisplay.utils.MulticastChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlin.coroutines.CoroutineContext

class AlertController {
    private val cache = mutableListOf<Throwable>()
    private val multiChannel = MulticastChannel<Throwable>()

    fun errors(context: CoroutineContext = Dispatchers.Default): ClosingChannel<Throwable> {
        val channel = this.multiChannel.makeChannel()
        if (this.cache.isNotEmpty()) {
            CoroutineScope(context).launch {
                while (cache.isNotEmpty()) {
                    val item = cache.removeAt(0)
                    channel.send(item)
                }
            }
        }
        return channel
    }

    suspend fun handle(error: Throwable) {
        if (!this.multiChannel.send(error)) {
            this.cache.add(error)
        }
    }
}