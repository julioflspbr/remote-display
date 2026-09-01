package dk.cipher.remotedisplay.display

import dk.cipher.remotedisplay.models.Cell
import dk.cipher.remotedisplay.models.Display
import dk.cipher.remotedisplay.models.Line
import dk.cipher.remotedisplay.views.display.DisplayViewModel
import dk.cipher.remotedisplay.views.display.EmptyKeyboardManager
import org.junit.Test
import junit.framework.TestCase.assertEquals

class DisplayViewModelTest {

    @Test
    fun `initial state`() {
        val sut = DisplayViewModel(EmptyKeyboardManager)

        assertEquals("", sut.text)
    }

    @Test
    fun `setText displays characters`() {
        val sut = DisplayViewModel(EmptyKeyboardManager)

        sut.setText("Hello")

        assertEquals("Hello", sut.text)
        assertEquals(Cell.Character('H'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character('e'), sut.display.lines[0].cells[1].value)
        assertEquals(Cell.Character('l'), sut.display.lines[0].cells[2].value)
        assertEquals(Cell.Character('l'), sut.display.lines[0].cells[3].value)
        assertEquals(Cell.Character('o'), sut.display.lines[0].cells[4].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[5].value)
    }

    @Test
    fun `setText places cursor`() {
        val sut = DisplayViewModel(EmptyKeyboardManager)

        sut.setText("abc")

        assertEquals(Cell.Cursor, sut.display.lines[0].cells[3].value)
    }

    @Test
    fun `setText handles newlines`() {
        val sut = DisplayViewModel(EmptyKeyboardManager)

        sut.setText("abc\ndef")

        assertEquals("abc\ndef", sut.text)
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
        val sut = DisplayViewModel(EmptyKeyboardManager)

        sut.setText("first")
        sut.setText("second")

        assertEquals("second", sut.text)
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
        val sut = DisplayViewModel(EmptyKeyboardManager)

        sut.setText("a😀b")

        assertEquals("ab", sut.text)
        assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[2].value)
    }

    @Test
    fun `insertText appends characters`() {
        val sut = DisplayViewModel(EmptyKeyboardManager)

        sut.setText("Hello")
        sut.insertText(" world")

        assertEquals("Hello world", sut.text)
        assertEquals(Cell.Character('H'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character(' '), sut.display.lines[0].cells[5].value)
        assertEquals(Cell.Character('d'), sut.display.lines[0].cells[10].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[11].value)
    }

    @Test
    fun `insertText handles newlines`() {
        val sut = DisplayViewModel(EmptyKeyboardManager)

        sut.setText("abc")
        sut.insertText("\ndef")

        assertEquals("abc\ndef", sut.text)
        assertEquals(Cell.Blank, sut.display.lines[0].cells[3].value)
        assertEquals(Cell.Character('d'), sut.display.lines[1].cells[0].value)
        assertEquals(Cell.Character('e'), sut.display.lines[1].cells[1].value)
        assertEquals(Cell.Character('f'), sut.display.lines[1].cells[2].value)
        assertEquals(Cell.Cursor, sut.display.lines[1].cells[3].value)
    }

    @Test
    fun `insertText ignores non ASCII characters`() {
        val sut = DisplayViewModel(EmptyKeyboardManager)

        sut.setText("ab")
        sut.insertText("😀cd")

        assertEquals("abcd", sut.text)
        assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        assertEquals(Cell.Character('c'), sut.display.lines[0].cells[2].value)
        assertEquals(Cell.Character('d'), sut.display.lines[0].cells[3].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[4].value)
    }

    @Test
    fun `deleteBackward on empty text`() {
        val sut = DisplayViewModel(EmptyKeyboardManager)

        sut.deleteBackward()

        assertEquals("", sut.text)
    }

    @Test
    fun `deleteBackward removes character`() {
        val sut = DisplayViewModel(EmptyKeyboardManager)

        sut.setText("abc")
        sut.deleteBackward()

        assertEquals("ab", sut.text)
        assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[2].value)
    }

    @Test
    fun `deleteBackward removes all characters`() {
        val sut = DisplayViewModel(EmptyKeyboardManager)

        sut.setText("abc")
        sut.deleteBackward()
        sut.deleteBackward()
        sut.deleteBackward()

        assertEquals("", sut.text)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[0].value)
    }

    @Test
    fun `deleteBackward across newline`() {
        val sut = DisplayViewModel(EmptyKeyboardManager)

        sut.setText("abc\ndef")
        sut.deleteBackward()
        sut.deleteBackward()
        sut.deleteBackward()
        sut.deleteBackward()

        assertEquals("abc", sut.text)
        assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        assertEquals(Cell.Character('c'), sut.display.lines[0].cells[2].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[3].value)
        assertEquals(Cell.Blank, sut.display.lines[1].cells[0].value)
    }

    @Test
    fun `deleteBackward removes newline`() {
        val sut = DisplayViewModel(EmptyKeyboardManager)

        sut.setText("abc\n")
        sut.deleteBackward()

        assertEquals("abc", sut.text)
        assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        assertEquals(Cell.Character('c'), sut.display.lines[0].cells[2].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[3].value)
    }

    @Test
    fun `setText respects line capacity`() {
        val sut = DisplayViewModel(EmptyKeyboardManager)

        val input = "a".repeat(Display.Specs.charCount + 10)

        sut.setText(input)

        assertEquals(Display.Specs.charCount, sut.text.length)
    }

    @Test
    fun `setText respects display line count`() {
        val input = (0 until Display.Specs.lineCount + 5)
            .joinToString("\n") { "a" }

        val sut = DisplayViewModel(EmptyKeyboardManager)

        sut.setText(input)

        assertEquals(Display.Specs.lineCount, sut.display.lines.size)
    }

    @Test
    fun `insertText respects display capacity`() {
        val sut = DisplayViewModel(EmptyKeyboardManager)

        val input = "a".repeat(
            Line.Specs.charCount * Display.Specs.lineCount + 10
        )

        sut.setText(input)

        assertEquals(
            Line.Specs.charCount * Display.Specs.lineCount,
            sut.text.length
        )
    }
}