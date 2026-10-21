package dk.cipher.remotedisplay.utils

import androidx.annotation.StringRes

abstract class LocalisedError(
    @StringRes open val errorDescription: Int? = null,
    @StringRes open val failureReason: Int? = null,
    @StringRes open val recoverySuggestion: Int? = null
): Throwable()