package dk.cipher.remotedisplay.display

import dk.cipher.remotedisplay.keyboard.Keyboard
import dk.cipher.remotedisplay.models.Cell
import dk.cipher.remotedisplay.views.display.DisplayViewModel
import org.junit.Test
import junit.framework.TestCase.assertEquals

class DisplayViewModelTest {
    @Test
    fun `setText displays characters`() {
        val sut = DisplayViewModel(EmptyKeyboardController())

        sut.setText("Hello")

        assertEquals(Cell.Character('H'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character('e'), sut.display.lines[0].cells[1].value)
        assertEquals(Cell.Character('l'), sut.display.lines[0].cells[2].value)
        assertEquals(Cell.Character('l'), sut.display.lines[0].cells[3].value)
        assertEquals(Cell.Character('o'), sut.display.lines[0].cells[4].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[5].value)
    }

    @Test
    fun `setText places cursor`() {
        val sut = DisplayViewModel(EmptyKeyboardController())

        sut.setText("abc")

        assertEquals(Cell.Cursor, sut.display.lines[0].cells[3].value)
    }

    @Test
    fun `setText handles newlines`() {
        val sut = DisplayViewModel(EmptyKeyboardController())

        sut.setText("abc\ndef")

        assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        assertEquals(Cell.Character('c'), sut.display.lines[0].cells[2].value)
        assertEquals(Cell.Blank, sut.display.lines[0].cells[3].value)
        assertEquals(Cell.Character('d'), sut.display.lines[1].cells[0].value)
        assertEquals(Cell.Character('e'), sut.display.lines[1].cells[1].value)
        assertEquals(Cell.Character('f'), sut.display.lines[1].cells[2].value)
        assertEquals(Cell.Cursor, sut.display.lines[1].cells[3].value)
    }

    @Test
    fun `setText resets previous contents`() {
        val sut = DisplayViewModel(EmptyKeyboardController())

        sut.setText("first")
        sut.setText("second")

        assertEquals(Cell.Character('s'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character('e'), sut.display.lines[0].cells[1].value)
        assertEquals(Cell.Character('c'), sut.display.lines[0].cells[2].value)
        assertEquals(Cell.Character('o'), sut.display.lines[0].cells[3].value)
        assertEquals(Cell.Character('n'), sut.display.lines[0].cells[4].value)
        assertEquals(Cell.Character('d'), sut.display.lines[0].cells[5].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[6].value)
    }

    @Test
    fun `setText ignores non ASCII characters`() {
        val sut = DisplayViewModel(EmptyKeyboardController())

        sut.setText("a😀b")

        assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[2].value)
    }

    @Test
    fun `insertText appends characters`() {
        val sut = DisplayViewModel(EmptyKeyboardController())

        sut.setText("Hello")
        sut.receive(Keyboard.Action.Text(" world"))

        assertEquals(Cell.Character('H'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character(' '), sut.display.lines[0].cells[5].value)
        assertEquals(Cell.Character('d'), sut.display.lines[0].cells[10].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[11].value)
    }

    @Test
    fun `insertText handles newlines`() {
        val sut = DisplayViewModel(EmptyKeyboardController())

        sut.setText("abc")
        sut.receive(Keyboard.Action.Text("\ndef"))

        assertEquals(Cell.Blank, sut.display.lines[0].cells[3].value)
        assertEquals(Cell.Character('d'), sut.display.lines[1].cells[0].value)
        assertEquals(Cell.Character('e'), sut.display.lines[1].cells[1].value)
        assertEquals(Cell.Character('f'), sut.display.lines[1].cells[2].value)
        assertEquals(Cell.Cursor, sut.display.lines[1].cells[3].value)
    }

    @Test
    fun `insertText ignores non ASCII characters`() {
        val sut = DisplayViewModel(EmptyKeyboardController())

        sut.setText("ab")
        sut.receive(Keyboard.Action.Text("😀cd"))

        assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        assertEquals(Cell.Character('c'), sut.display.lines[0].cells[2].value)
        assertEquals(Cell.Character('d'), sut.display.lines[0].cells[3].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[4].value)
    }

    @Test
    fun `deleteBackward removes character`() {
        val sut = DisplayViewModel(EmptyKeyboardController())

        sut.setText("abc")
        sut.receive(Keyboard.Action.Backspace)

        assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[2].value)
    }

    @Test
    fun `deleteBackward removes all characters`() {
        val sut = DisplayViewModel(EmptyKeyboardController())

        sut.setText("abc")
        sut.receive(Keyboard.Action.Backspace)
        sut.receive(Keyboard.Action.Backspace)
        sut.receive(Keyboard.Action.Backspace)

        assertEquals(Cell.Cursor, sut.display.lines[0].cells[0].value)
    }

    @Test
    fun `deleteBackward across newline`(){
        val sut = DisplayViewModel(EmptyKeyboardController())

        sut.setText("abc\ndef")
        sut.receive(Keyboard.Action.Backspace)
        sut.receive(Keyboard.Action.Backspace)
        sut.receive(Keyboard.Action.Backspace)
        sut.receive(Keyboard.Action.Backspace)

        assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        assertEquals(Cell.Character('c'), sut.display.lines[0].cells[2].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[3].value)
        assertEquals(Cell.Blank, sut.display.lines[1].cells[0].value)
    }

    @Test
    fun `deleteBackward removes newline`() {
        val sut = DisplayViewModel(EmptyKeyboardController())

        sut.setText("abc\n")
        sut.receive(Keyboard.Action.Backspace)

        assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        assertEquals(Cell.Character('c'), sut.display.lines[0].cells[2].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[3].value)
    }

    private class EmptyKeyboardController: Keyboard.Controller {
        override var canShowKeyboard = false

        override fun insertText(text: String) {
        }

        override fun deleteBackward() {
        }

        override fun toggleKeyboard() {
        }

        override fun setService(service: Keyboard.Service) {
        }

        override fun subscribe(client: Keyboard.Client) {
        }

        override fun unsubscribe(client: Keyboard.Client) {
        }
    }
}