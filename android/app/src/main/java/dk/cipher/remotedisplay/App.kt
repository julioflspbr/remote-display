package dk.cipher.remotedisplay

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.enableEdgeToEdge
import dk.cipher.remotedisplay.keyboard.KeyboardController
import dk.cipher.remotedisplay.services.ServiceController
import dk.cipher.remotedisplay.ui.views.content.ContentView

class App : ComponentActivity() {
    lateinit var keyboardController: KeyboardController
        private set
    lateinit var serviceController: ServiceController
        private set

    override fun onCreate(savedInstanceState: Bundle?) {
        shared = this
        this.keyboardController = Dependencies.keyboardController()
        this.serviceController = Dependencies.serviceController()

        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(
            ContentView(
                this,
                ContentView.Dependencies(
                    keyboardController,
                    serviceController
                )
            )
        )
    }

    object Dependencies {
        fun keyboardController() =
            KeyboardController().apply { this.canShowKeyboard = true }
        fun serviceController() =
            ServiceController(ServiceController.Dependencies.live())
    }

    companion object {
        lateinit var shared: App
            private set
    }
}