package dk.cipher.remotedisplay.keyboard

interface Toggler {
    fun toggleKeyboard()
}

object EmptyToggler: Toggler {
    override fun toggleKeyboard() {
    }
}