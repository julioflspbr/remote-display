package dk.cipher.remotedisplay.ui.views.services

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import dk.cipher.remotedisplay.R
import dk.cipher.remotedisplay.services.ServiceController
import dk.cipher.remotedisplay.services.Services
import dk.cipher.remotedisplay.services.preview
import dk.cipher.remotedisplay.utils.previewBackground

@Composable
fun ServicesView(serviceController: ServiceController, modifier: Modifier = Modifier) {
    val viewModel: ServiceViewModel = viewModel(
        factory = ServiceViewModel.build(serviceController)
    )

    Column(
        modifier = modifier
    ) {
        for (service in viewModel.services) {
            ServiceButton(
                image = service.icon,
                color = service.status.color(),
                isTransient = service.status.isTransient,
                modifier = Modifier.size(40.dp)
            )
        }
    }
}

@Preview(widthDp = 40, heightDp = 160)
@Composable
fun ServicesPreview() {
    ServicesView(
        serviceController = ServiceController.preview(listOf(
            Pair(painterResource(R.drawable.bluetooth), Services.Status.Unavailable),
            Pair(painterResource(R.drawable.cloud), Services.Status.Available),
            Pair(painterResource(R.drawable.wifi), Services.Status.Connecting),
            Pair(painterResource(R.drawable.smoke), Services.Status.Searching)
        )),
        modifier = Modifier.previewBackground()
    )
}