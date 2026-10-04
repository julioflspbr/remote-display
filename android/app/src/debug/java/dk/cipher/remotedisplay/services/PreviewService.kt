package dk.cipher.remotedisplay.services

import androidx.compose.ui.graphics.painter.Painter
import dk.cipher.remotedisplay.ui.views.services.ServiceWithIcon

class PreviewService(override val icon: Painter, override val status: Services.Status = Services.Status.Unavailable): ServiceWithIcon {
    override suspend fun search() {
        // just preview, nothing to do
    }

    override suspend fun connect() {
        // just preview, nothing to do
    }

    override suspend fun disconnect() {
        // just preview, nothing to do
    }

    override fun setDelegate(delegate: Services.ServiceDelegate) {
        // just preview, nothing to do
    }
}