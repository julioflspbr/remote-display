package dk.cipher.remotedisplay

import android.annotation.SuppressLint
import android.content.Context
import dk.cipher.remotedisplay.keyboard.KeyboardController
import dk.cipher.remotedisplay.services.ServiceController

@SuppressLint("StaticFieldLeak")
object App {
    var context: Context? = null
    val keyboardController = KeyboardController()
    private var serviceController: ServiceController? =
        ServiceController(ServiceController.Dependencies.live(context!!))
}