package dk.cipher.remotedisplay.utils

import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.channels.ChannelIterator
import kotlinx.coroutines.channels.ClosedReceiveChannelException

class ClosingChannel<T>(val onClose: (ClosingChannel<T>) -> Unit): ChannelIterator<T> {
    private var value: T? = null
    val channel: Channel<T> = Channel()

    suspend fun send(element: T) =
        this.channel.send(element)

    fun close(cause: Throwable? = null) {
        this.channel.close(cause)
        this.onClose.invoke(this)
    }

    operator fun iterator(): ChannelIterator<T> = this

    override suspend fun hasNext(): Boolean {
        try {
            val value = this.channel.receive()
            this.value = value
            return true
        } catch (_: ClosedReceiveChannelException) {
            return false
        }
    }

    override fun next(): T =
        this.value ?: error("It is an error to call the next element when there are no more elements in the channel. Check hasNext() first.")
}