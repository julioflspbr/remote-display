package dk.cipher.remotedisplay.views.display

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import dk.cipher.remotedisplay.keyboard.Action
import dk.cipher.remotedisplay.keyboard.Controller
import dk.cipher.remotedisplay.keyboard.Forwarder
import dk.cipher.remotedisplay.models.Cell
import dk.cipher.remotedisplay.models.Display
import dk.cipher.remotedisplay.models.Line
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

class DisplayViewModel(dependencies: Dependencies): ViewModel() {
    data class Dependencies(val keyEvents: Forwarder, val keyEventSubscriptionContext: Subscription) {
        typealias Subscription = (suspend () -> Unit) -> Job

        companion object {
            fun live() =
                Dependencies(
                    keyEvents = Controller.shared,
                    keyEventSubscriptionContext = { operation ->
                        CoroutineScope(Dispatchers.Main).launch { operation() }
                    }
                )
        }
    }

    companion object {
        fun build(dependencies: Dependencies): ViewModelProvider.Factory =
            viewModelFactory {
                initializer {
                    DisplayViewModel(dependencies)
                }
            }
    }

    var display = Display()
    private val positions = mutableListOf<Int>()
    private val keyPressJob: Job

    private var currentCell: Cell
        get() {
            return display.lines[positions.lastIndex].cells[positions.last()].value
        }
        set(newValue) {
            display.lines[positions.lastIndex].cells[positions.last()].value = newValue
        }

    init {
        keyPressJob = dependencies.keyEventSubscriptionContext {
            for (input in dependencies.keyEvents.keyboardAction) {
                when (input) {
                    is Action.Text -> insertText(input.text)
                    is Action.Backspace -> deleteBackward()
                }
            }
        }
    }

    fun finalize() {
        keyPressJob.cancel()
    }

    fun setText(text: CharSequence) {
        positions.clear()
        display = Display()
        insertText(text)
    }

    private fun deleteBackward() {
        if (positions.isEmpty() || positions.first() <= 0) {
            return
        }

        if (positions.last() < Line.Specs.charCount) {
            currentCell = Cell.Blank
        }
        positions[positions.lastIndex] -= 1
        if (positions.last() < 0) {
            positions.removeAt(positions.lastIndex)
            if (positions.last() >= Line.Specs.charCount) {
                positions[positions.lastIndex] = Line.Specs.charCount - 1
            }
        }
        if (positions.lastIndex < Display.Specs.lineCount && positions.last() < Line.Specs.charCount) {
            currentCell = Cell.Cursor
        }
    }

    private fun insertText(text: CharSequence) {
        if (positions.isEmpty()) {
            positions.add(0)
        }
        for (c in text) {
            if (c.isNewLine()) {
                if (positions.size < Display.Specs.lineCount && positions.last() > 0) {
                    currentCell = Cell.Blank
                    positions.add(0)
                }
            } else if (c.isAscii()) {
                if (positions.lastIndex >= Display.Specs.lineCount || positions.last() >= Line.Specs.charCount) {
                    break
                }
                currentCell = Cell.Character(c)
                positions[positions.lastIndex] += 1
                if (positions.last() >= Line.Specs.charCount && positions.size < Display.Specs.lineCount) {
                    positions.add(0)
                }
            }
        }
        if (positions.lastIndex < Display.Specs.lineCount && positions.last() < Line.Specs.charCount) {
            currentCell = Cell.Cursor
        }
    }
}

private fun Char.isAscii(): Boolean = (this.code < 127)
private fun Char.isNewLine(): Boolean = (this == '\n' || this == '\r')