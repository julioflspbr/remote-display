package dk.cipher.remotedisplay.keyboard

import dk.cipher.remotedisplay.keyboard.Keyboard.Action

class KeyboardController : Keyboard.Controller {
    private var service: Keyboard.Service? = null
    private var subscriptions = mutableSetOf<Keyboard.Client>()
    private var isShowingKeyboard = false
    private var _canShowKeyboard = false
    override var canShowKeyboard: Boolean
        get() = _canShowKeyboard
        set(value) {
            _canShowKeyboard = value
            if (!_canShowKeyboard) {
                this.service?.hideKeyboard()
                this.isShowingKeyboard = false
            }
        }

    override fun toggleKeyboard() {
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

    override fun setService(service: Keyboard.Service) {
        this.service = service
    }

    override fun subscribe(client: Keyboard.Client) {
        this.subscriptions.add(client)
    }

    override fun unsubscribe(client: Keyboard.Client) {
        this.subscriptions.remove(client)
    }

    override fun insertText(text: String) {
        if (text.isEmpty()) {
            return
        }
        for (client in this.subscriptions) {
            client.receive(Action.Text(text))
        }
    }

    override fun deleteBackward() {
        for (client in this.subscriptions) {
            client.receive(Action.Backspace)
        }
    }
}