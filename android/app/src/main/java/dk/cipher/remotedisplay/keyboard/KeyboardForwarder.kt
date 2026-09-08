package dk.cipher.remotedisplay.keyboard

import kotlinx.coroutines.channels.Channel

interface KeyboardForwarder {
    val keyboardAction: Channel<KeyboardAction>
    fun endChannel()
}