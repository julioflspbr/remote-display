package dk.cipher.remotedisplay.views

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.enableEdgeToEdge
import dk.cipher.remotedisplay.views.display.DisplayView

class MainActivity : ComponentActivity() {
    private lateinit var root: KeyboardResponder

    override fun onCreate(savedInstanceState: Bundle?) {
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