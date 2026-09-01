package dk.cipher.remotedisplay.views

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.enableEdgeToEdge
import dk.cipher.remotedisplay.views.display.DisplayView

class MainActivity : ComponentActivity() {
    private lateinit var root: FocusableComposeView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        root = FocusableComposeView(this).apply {
            setContent {
                DisplayView(root, "Lalalones!!!")
            }
        }

        setContentView(root)
    }
}