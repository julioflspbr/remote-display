package dk.cipher.remotedisplay.views.display

interface KeyboardManager {
    fun insertText(handler: (CharSequence) -> Boolean)
    fun deleteBackward(handler: () -> Boolean)
    fun showKeyboard()
    fun hideKeyboard()
    fun isShowingKeyboard(): Boolean
}

object EmptyKeyboardManager: KeyboardManager {
    override fun insertText(handler: (CharSequence) -> Boolean) {
    }

    override fun deleteBackward(handler: () -> Boolean) {
    }

    override fun showKeyboard() {
    }

    override fun hideKeyboard() {
    }

    override fun isShowingKeyboard(): Boolean {
        return false
    }
}