package dk.cipher.remotedisplay.utils

import dk.cipher.remotedisplay.RemoteDisplayApp

abstract class Error(val messageStringResource: Int): Throwable() {
    override val message: String?
        get() = RemoteDisplayApp.shared.getString(messageStringResource)
}