package dk.cipher.remotedisplay.views.character

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlin.time.Duration
import kotlin.time.Duration.Companion.milliseconds

class CharacterViewModel(val blinkInterval: Duration = 500.milliseconds): ViewModel() {
    companion object {
        fun build(): ViewModelProvider.Factory =
            viewModelFactory {
                initializer {
                    CharacterViewModel()
                }
            }
    }

    var showCursor by mutableStateOf(true)

    private var blinkerJob: Job? = null

    fun blink() {
        blinkerJob?.cancel()
        blinkerJob = viewModelScope.launch {
            while (isActive) {
                delay(blinkInterval)
                showCursor = !showCursor
            }
        }
    }

    fun steady() {
        blinkerJob?.cancel()
        blinkerJob = null
        showCursor = false
    }

    override fun onCleared() {
        blinkerJob?.cancel()
    }
}