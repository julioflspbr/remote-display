package dk.cipher.remotedisplay.ui.views.services

import androidx.compose.ui.graphics.painter.Painter
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import dk.cipher.remotedisplay.services.ServiceController
import dk.cipher.remotedisplay.services.Services
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class ServiceViewModel(controller: ServiceController): ViewModel(), Services.ServiceDelegate {
    data class DisplayService(
        val id: Int,
        val icon: Painter,
        val status: Services.Status
    )

    companion object {
        fun build(controller: ServiceController) =
            viewModelFactory {
                initializer {
                    ServiceViewModel(controller)
                }
            }
    }

    private val _services =
        controller.builtIn.mapNotNull({ service ->
            if (service is ServiceWithIcon) {
                val displayService = service.toDisplay()
                Pair(displayService.id, displayService)
            } else {
                null
            }
        }).toMap().toMutableMap()

    val services: List<DisplayService>
        get() = _services.values.toList()

    init {
        controller.setDelegate(this)
        CoroutineScope(SupervisorJob()).launch {
            controller.autoConnect()
        }
    }

    override fun serviceDidUpdateStatus(service: Services.Service) {
        if (service is ServiceWithIcon) {
            _services[service.hashCode()] = service.toDisplay()
        }
    }
}

private fun ServiceWithIcon.toDisplay() =
    ServiceViewModel.DisplayService(this.hashCode(), this.icon, this.status)