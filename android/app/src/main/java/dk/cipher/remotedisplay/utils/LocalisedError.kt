package dk.cipher.remotedisplay.utils

import androidx.annotation.StringRes

abstract class LocalisedError(
    @StringRes val errorDescription: Int? = null,
    @StringRes val failureReason: Int? = null,
    @StringRes val recoverySuggestion: Int? = null
): Throwable()