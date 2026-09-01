package dk.cipher.remotedisplay.views.display

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import dk.cipher.remotedisplay.models.Cell
import dk.cipher.remotedisplay.models.Display
import dk.cipher.remotedisplay.models.Line

class DisplayViewModel(private val input: KeyboardManager): ViewModel() {
    companion object {
        fun build(input: KeyboardManager): ViewModelProvider.Factory =
            viewModelFactory {
                initializer {
                    DisplayViewModel(input)
                }
            }
    }

    var text = ""
    val display = Display()
    private val positions = mutableListOf<Int>()

    private var currentLineFirstCell: Cell
        get() {
            return display.lines[positions.lastIndex].cells[0].value
        }
        set(newValue) {
            display.lines[positions.lastIndex].cells[0].value = newValue
        }

    private var currentCell: Cell
        get() {
            return display.lines[positions.lastIndex].cells[positions.last()].value
        }
        set(newValue) {
            display.lines[positions.lastIndex].cells[positions.last()].value = newValue
        }

    init {
        input.insertText {
            insertText(it)
        }
        input.deleteBackward {
            deleteBackward()
        }
    }

    fun setText(text: CharSequence) {
        positions.clear()
        this.text = fillUpDisplay(text)
    }

    fun toggleKeyboard() {
        if (input.isShowingKeyboard()) {
            input.hideKeyboard()
        } else {
            input.showKeyboard()
        }
    }

    fun insertText(text: CharSequence): Boolean {
        val toAppend = fillUpDisplay(text)
        if (toAppend.isEmpty()) {
            return false
        }
        this.text += toAppend
        return true
    }

    fun deleteBackward(): Boolean {
        if (text.isEmpty()) {
            return false
        }

        val c = text.last()
        text = text.removeSuffix("$c")

        if (c.isNewLine()) {
            currentLineFirstCell = Cell.Blank
            positions.removeAt(positions.lastIndex)
        } else {
            if (positions.last() < Line.Specs.charCount) {
                currentCell = Cell.Blank
            }
            positions[positions.lastIndex] -= 1
            if (positions.last() < 0) {
                positions.removeAt(positions.lastIndex)
                positions[positions.lastIndex] -= 1
            }
        }
        if (positions.lastIndex < Display.Specs.lineCount && positions.last() < Line.Specs.charCount) {
            currentCell = Cell.Cursor
        }

        return true
    }

    private fun fillUpDisplay(text: CharSequence): String {
        if (positions.isEmpty()) {
            positions.add(0)
        }
        var result = ""
        for (charCode in text.chars()) {
            val c = Char(charCode)
            if (c.isNewLine()) {
                if (positions.count() < Display.Specs.lineCount) {
                    result += c
                    currentCell = Cell.Blank
                    positions.add(0)
                }
            } else if (c.isAscii()) {
                if (positions.lastIndex >= Display.Specs.lineCount || positions.last() >= Line.Specs.charCount) {
                    break
                }
                result += c
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

        return result
    }
}

private fun Char.isAscii(): Boolean = (this.code < 127)
private fun Char.isNewLine(): Boolean = (this == '\n' || this == '\r')