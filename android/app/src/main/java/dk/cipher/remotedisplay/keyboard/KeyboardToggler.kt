package dk.cipher.remotedisplay.keyboard

interface KeyboardToggler {
    fun toggleKeyboard()
}

object EmptyKeyboardToggler: KeyboardToggler {
    override fun toggleKeyboard() {
    }
}