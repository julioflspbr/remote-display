package dk.cipher.remotedisplay.keyboard

import kotlinx.coroutines.channels.Channel

interface Forwarder {
    val keyboardAction: Channel<Action>
    fun endChannel()
}