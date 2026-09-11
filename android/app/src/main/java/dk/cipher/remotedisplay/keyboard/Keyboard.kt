package dk.cipher.remotedisplay.keyboard

object Keyboard {
    sealed interface Action {
        data class Text(val text: String) : Action
        object Backspace : Action
    }

    interface Service {
        fun showKeyboard()
        fun hideKeyboard()
    }

    interface Client {
        fun receive(action: Action)
    }

    interface Controller {
        var canShowKeyboard: Boolean
        fun insertText(text: String)
        fun deleteBackward()
        fun toggleKeyboard()
        fun setService(service: Service)
        fun subscribe(client: Client)
        fun unsubscribe(client: Client)
    }
}