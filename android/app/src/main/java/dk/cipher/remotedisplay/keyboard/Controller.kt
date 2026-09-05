package dk.cipher.remotedisplay.keyboard

import kotlinx.coroutines.channels.Channel

class Controller: Forwarder, Receiver {
    companion object {
        val shared = Controller()
    }
    private var subscriptions = mutableSetOf<Channel<Action>>()

    fun finalize() {
        for (subscription in subscriptions) {
            subscription.close()
        }
    }

    override val keyboardAction: Channel<Action>
        get() {
             val channel = Channel<Action>()
            subscriptions.add(channel)
            return channel
        }

    override fun endChannel() {
        for (subscription in subscriptions) {
            subscription.close()
        }
        subscriptions.clear()
    }

    override suspend fun insertText(text: String) {
        if (text.isEmpty()) {
            return
        }
        for (subscription in subscriptions) {
            subscription.send(Action.Text(text))
        }
    }

    override suspend fun deleteBackward() {
        for (subscription in subscriptions) {
            subscription.send(Action.Backspace)
        }
    }
}