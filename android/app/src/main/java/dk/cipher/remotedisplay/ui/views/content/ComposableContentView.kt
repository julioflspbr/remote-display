package dk.cipher.remotedisplay.ui.views.content

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import dk.cipher.remotedisplay.R
import dk.cipher.remotedisplay.alert.AlertController
import dk.cipher.remotedisplay.keyboard.KeyboardController
import dk.cipher.remotedisplay.services.ServiceController
import dk.cipher.remotedisplay.services.Services
import dk.cipher.remotedisplay.services.preview
import dk.cipher.remotedisplay.ui.views.alert.AlertView
import dk.cipher.remotedisplay.ui.views.display.DisplayView
import dk.cipher.remotedisplay.ui.views.services.ServicesView
import dk.cipher.remotedisplay.utils.previewBackground

@Composable
fun ComposableContentView(dependencies: ContentView.Dependencies) {
    Column(
        modifier = Modifier.previewBackground(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(20.dp)
    ) {
        Row(
            horizontalArrangement = Arrangement.Center
        ) {
            ServicesView(
                serviceController = dependencies.serviceController,
                modifier = Modifier.padding(horizontal = 10.dp)
            )
            DisplayView(
                text = "0123456789012345",
                keyboardController = dependencies.keyboardController
            )
            ServicesView(
                serviceController = dependencies.serviceController,
                modifier = Modifier.padding(horizontal = 10.dp)
            )
        }

        AlertView(dependencies.alertController)
    }
}

@Composable @Preview(widthDp = 915, heightDp = 412)
fun ContentPreview() {
    ComposableContentView(ContentView.Dependencies(
        keyboardController = KeyboardController(),
        serviceController = ServiceController.preview(listOf(
            Pair(painterResource(R.drawable.bluetooth), Services.Status.Unavailable),
            Pair(painterResource(R.drawable.cloud), Services.Status.Available),
            Pair(painterResource(R.drawable.wifi), Services.Status.Connecting)
        )),
        alertController = AlertController()
    ))
}