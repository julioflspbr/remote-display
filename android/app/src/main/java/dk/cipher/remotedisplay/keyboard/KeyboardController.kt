package dk.cipher.remotedisplay.keyboard

import kotlinx.coroutines.channels.Channel

class KeyboardController: KeyboardForwarder, KeyboardReceiver {
    companion object {
        val shared = KeyboardController()
    }
    private var subscriptions = mutableSetOf<Channel<KeyboardAction>>()

    fun finalize() {
        for (subscription in subscriptions) {
            subscription.close()
        }
    }

    override val keyboardAction: Channel<KeyboardAction>
        get() {
             val channel = Channel<KeyboardAction>()
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
            subscription.send(KeyboardAction.Text(text))
        }
    }

    override suspend fun deleteBackward() {
        for (subscription in subscriptions) {
            subscription.send(KeyboardAction.Backspace)
        }
    }
}