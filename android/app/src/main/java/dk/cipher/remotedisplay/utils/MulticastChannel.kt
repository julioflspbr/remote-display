package dk.cipher.remotedisplay.utils

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MulticastChannel<Element> {
    private var subscriptions = mutableListOf<ClosingChannel<Element>>()

    fun makeChannel(): ClosingChannel<Element> {
        val channel = ClosingChannel {
            this.subscriptions.remove(it)
        }
        this.subscriptions.add(channel)
        return channel
    }

    suspend fun send(value: Element): Boolean {
        if (this.subscriptions.isEmpty()) {
            return false
        }
        for (subscription in this.subscriptions) {
            subscription.send(value)
        }
        return true
    }

    fun close() {
        for (subscription in this.subscriptions) {
            CoroutineScope(Dispatchers.Default).launch {
                subscription.close()
            }
        }
    }
}