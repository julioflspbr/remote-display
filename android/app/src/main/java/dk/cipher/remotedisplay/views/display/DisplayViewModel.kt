package dk.cipher.remotedisplay.views.display

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import dk.cipher.remotedisplay.keyboard.Keyboard
import dk.cipher.remotedisplay.models.Cell
import dk.cipher.remotedisplay.models.Display
import dk.cipher.remotedisplay.models.Line

class DisplayViewModel(val keyboardController: Keyboard.Controller): ViewModel(), Keyboard.Client {
    companion object {
        fun build(keyboardController: Keyboard.Controller) =
            viewModelFactory {
                initializer {
                    DisplayViewModel(keyboardController)
                }
            }
    }

    var display = Display()
    private val positions = mutableListOf<Int>()
    private var currentCell: Cell
        get() {
            return display.lines[positions.lastIndex].cells[positions.last()].value
        }
        set(newValue) {
            display.lines[positions.lastIndex].cells[positions.last()].value = newValue
        }

    init {
        this.keyboardController.subscribe(this)
    }

    override fun onCleared() {
        this.keyboardController.unsubscribe(this)
    }

    override fun receive(action: Keyboard.Action) {
        when (action) {
            is Keyboard.Action.Text -> this.insertText(action.text)
            is Keyboard.Action.Backspace -> this.deleteBackward()
        }
    }
    fun setText(text: CharSequence) {
        positions.clear()
        display = Display()
        insertText(text)
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
}

private fun Char.isAscii(): Boolean = (this.code < 127)
private fun Char.isNewLine(): Boolean = (this == '\n' || this == '\r')