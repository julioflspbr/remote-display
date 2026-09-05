package dk.cipher.remotedisplay.keyboard

sealed interface Action {
    data class Text(val text: String): Action
    object Backspace: Action
}