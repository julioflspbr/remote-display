package dk.cipher.remotedisplay.ui.views

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.enableEdgeToEdge
import dk.cipher.remotedisplay.App
import dk.cipher.remotedisplay.ui.views.display.DisplayView

class MainActivity : ComponentActivity() {
    private lateinit var root: KeyboardResponder

    override fun onCreate(savedInstanceState: Bundle?) {
        // initialise app singletons
        App.context = this

        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        root = KeyboardResponder(this).apply {
            setContent {
                DisplayView("Uh la la la")
            }
        }

        setContentView(root)
    }
}