package dk.cipher.remotedisplay.keyboard

sealed interface KeyboardAction {
    data class Text(val text: String): KeyboardAction
    object Backspace: KeyboardAction
}