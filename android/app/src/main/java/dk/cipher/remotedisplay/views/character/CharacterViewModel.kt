package dk.cipher.remotedisplay.views.character

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import java.util.Timer
import kotlin.concurrent.timer

class CharacterViewModel(val blinkInterval: Long = 500/* ms */): ViewModel() {
    var showCursor by mutableStateOf(true)

    private var blinkTimer: Timer? = null

    fun blink() {
        blinkTimer?.cancel()
        this.blinkTimer = timer(name = "Character Blinker", initialDelay = blinkInterval, period = blinkInterval) {
            showCursor = !showCursor
        }
    }

    fun steady() {
        blinkTimer?.cancel()
        blinkTimer = null
        showCursor = false
    }

    override fun onCleared() {
        blinkTimer?.cancel()
    }
}