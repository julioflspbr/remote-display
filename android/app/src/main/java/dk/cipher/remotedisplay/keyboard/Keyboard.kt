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
}