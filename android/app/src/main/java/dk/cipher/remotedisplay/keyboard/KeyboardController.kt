package dk.cipher.remotedisplay.keyboard

import dk.cipher.remotedisplay.keyboard.Keyboard.Action
import dk.cipher.remotedisplay.utils.ClosingChannel
import dk.cipher.remotedisplay.utils.MulticastChannel
import kotlinx.coroutines.channels.Channel

class KeyboardController {
    private var service: Keyboard.Service? = null
    private val multiChannel = MulticastChannel<Action>()
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

    fun actions(): ClosingChannel<Action> =
        this.multiChannel.makeChannel()

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
        this.multiChannel.send(Action.Text(text))
    }

    suspend fun deleteBackward() {
        this.multiChannel.send(Action.Backspace)
    }
}