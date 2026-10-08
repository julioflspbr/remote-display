package dk.cipher.remotedisplay.services

import androidx.compose.ui.graphics.painter.Painter
import dk.cipher.remotedisplay.ui.views.services.ServiceWithIcon

fun ServiceController.Companion.preview(services: List<Pair<Painter, Services.Status>>) =
    ServiceController(ServiceController.Dependencies.preview(
        services.map { (icon, status) ->
            PreviewService(icon, status) as ServiceWithIcon
        }
    ))

private fun ServiceController.Dependencies.Companion.preview(services: List<ServiceWithIcon>) =
    ServiceController.Dependencies(
        context = null,
        autoConnect = null,
        builtInServices = services
    )