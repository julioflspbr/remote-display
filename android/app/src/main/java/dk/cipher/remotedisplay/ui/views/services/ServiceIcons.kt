package dk.cipher.remotedisplay.ui.views.services

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.res.colorResource
import dk.cipher.remotedisplay.R
import dk.cipher.remotedisplay.services.Services

interface ServiceWithIcon: Services.Service {
    val icon: Painter
}

@Composable
fun Services.Status.color() =
    when (this) {
        is Services.Status.Unavailable,
        is Services.Status.Disconnecting,
        is Services.Status.Disconnected ->
            colorResource(R.color.service_unavailable)

        is Services.Status.Searching,
        is Services.Status.Available ->
            colorResource(R.color.service_available)

        is Services.Status.Connecting,
        is Services.Status.Connected ->
            colorResource(R.color.service_connected)

        is Services.Status.Failure ->
            colorResource(R.color.service_failed)
    }

val Services.Status.isTransient: Boolean
    get() = when (this) {
        is Services.Status.Disconnecting,
            is Services.Status.Searching,
            is Services.Status.Connecting ->
                true

        is Services.Status.Unavailable,
            is Services.Status.Disconnected,
            is Services.Status.Available,
            is Services.Status.Connected,
            is Services.Status.Failure ->
                false
    }