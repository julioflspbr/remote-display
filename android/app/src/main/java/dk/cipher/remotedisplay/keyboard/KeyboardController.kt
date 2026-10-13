package dk.cipher.remotedisplay.keyboard

import dk.cipher.remotedisplay.keyboard.Keyboard.Action
import dk.cipher.remotedisplay.utils.ClosingChannel

class KeyboardController {
    private var service: Keyboard.Service? = null
    private var subscriptions = mutableSetOf<ClosingChannel<Action>>()
    private var isShowingKeyboard = false
    private var _canShowKeyboard = false
    var canShowKeyboard: Boolean
        get() = _canShowKeyboard
        set(value) {
            _canShowKeyboard = value
            if (!_canShowKeyboard) {
                this.service?.hideKeyboard()
                this.isShowingKeyboard = false
            }
        }

    val actions: ClosingChannel<Action>
        get() {
            val channel = ClosingChannel<Action> { channel ->
                this.subscriptions.remove(channel)
            }
            this.subscriptions.add(channel)
            return channel
        }

    fun toggleKeyboard() {
        val service = this.service
        if (service == null || !this.canShowKeyboard) {
            return
        }
        if (this.isShowingKeyboard) {
            service.hideKeyboard()
            this.isShowingKeyboard = false
        } else {
            service.showKeyboard()
            this.isShowingKeyboard = true
        }
    }

    fun setService(service: Keyboard.Service) {
        this.service = service
    }

    suspend fun insertText(text: String) {
        if (text.isEmpty()) {
            return
        }
        for (client in this.subscriptions) {
            client.send(Action.Text(text))
        }
    }

    suspend fun deleteBackward() {
        for (client in this.subscriptions) {
            client.send(Action.Backspace)
        }
    }
}