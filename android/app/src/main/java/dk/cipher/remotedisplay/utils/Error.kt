package dk.cipher.remotedisplay.utils

import dk.cipher.remotedisplay.App

abstract class Error(val messageStringResource: Int): Throwable() {
    override val message: String?
        get() = App.shared.getString(messageStringResource)
}