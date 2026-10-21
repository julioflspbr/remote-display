package dk.cipher.remotedisplay.utils

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlin.coroutines.CoroutineContext

class Subscriber<Value> {
    val accumulated = mutableListOf<Value>()

    fun subscribe(channel: ClosingChannel<Value>, context: CoroutineContext): Job =
        CoroutineScope(context).launch {
            for (value in channel) {
                accumulated.add(value)
            }
        }
}