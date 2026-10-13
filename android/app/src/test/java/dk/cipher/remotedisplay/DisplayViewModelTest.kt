package dk.cipher.remotedisplay

import dk.cipher.remotedisplay.keyboard.KeyboardController
import dk.cipher.remotedisplay.ui.models.Cell
import dk.cipher.remotedisplay.ui.views.display.DisplayViewModel
import junit.framework.TestCase
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.Test

class DisplayViewModelTest {
    @Test
    fun `setText displays characters`() {
        // given
        val sut = DisplayViewModel()

        // when
        sut.setText("Hello")

        // then
        TestCase.assertEquals(Cell.Character('H'), sut.display.lines[0].cells[0].value)
        TestCase.assertEquals(Cell.Character('e'), sut.display.lines[0].cells[1].value)
        TestCase.assertEquals(Cell.Character('l'), sut.display.lines[0].cells[2].value)
        TestCase.assertEquals(Cell.Character('l'), sut.display.lines[0].cells[3].value)
        TestCase.assertEquals(Cell.Character('o'), sut.display.lines[0].cells[4].value)
        TestCase.assertEquals(Cell.Cursor, sut.display.lines[0].cells[5].value)
    }

    @Test
    fun `setText places cursor`() {
        // given
        val sut = DisplayViewModel()

        // when
        sut.setText("abc")

        // then
        TestCase.assertEquals(Cell.Cursor, sut.display.lines[0].cells[3].value)
    }

    @Test
    fun `setText handles newlines`() {
        // given
        val sut = DisplayViewModel()

        // when
        sut.setText("abc\ndef")

        // then
        TestCase.assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        TestCase.assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        TestCase.assertEquals(Cell.Character('c'), sut.display.lines[0].cells[2].value)
        TestCase.assertEquals(Cell.Blank, sut.display.lines[0].cells[3].value)
        TestCase.assertEquals(Cell.Character('d'), sut.display.lines[1].cells[0].value)
        TestCase.assertEquals(Cell.Character('e'), sut.display.lines[1].cells[1].value)
        TestCase.assertEquals(Cell.Character('f'), sut.display.lines[1].cells[2].value)
        TestCase.assertEquals(Cell.Cursor, sut.display.lines[1].cells[3].value)
    }

    @Test
    fun `setText resets previous contents`() {
        // given
        val sut = DisplayViewModel()

        // when
        sut.setText("first")
        sut.setText("second")

        // then
        TestCase.assertEquals(Cell.Character('s'), sut.display.lines[0].cells[0].value)
        TestCase.assertEquals(Cell.Character('e'), sut.display.lines[0].cells[1].value)
        TestCase.assertEquals(Cell.Character('c'), sut.display.lines[0].cells[2].value)
        TestCase.assertEquals(Cell.Character('o'), sut.display.lines[0].cells[3].value)
        TestCase.assertEquals(Cell.Character('n'), sut.display.lines[0].cells[4].value)
        TestCase.assertEquals(Cell.Character('d'), sut.display.lines[0].cells[5].value)
        TestCase.assertEquals(Cell.Cursor, sut.display.lines[0].cells[6].value)
    }

    @Test
    fun `setText ignores non ASCII characters`() {
        // given
        val sut = DisplayViewModel()

        // when
        sut.setText("a😀b")

        // then
        TestCase.assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        TestCase.assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        TestCase.assertEquals(Cell.Cursor, sut.display.lines[0].cells[2].value)
    }

    @Test
    fun `insertText appends characters`() = runTest {
        // given
        val keyboardController = KeyboardController()
        val sut = DisplayViewModel()
        sut.startListeningToKeyboard(keyboardController, StandardTestDispatcher(testScheduler))
        testScheduler.advanceUntilIdle()

        // when
        sut.setText("Hello")
        keyboardController.insertText(" world")

        // then
        testScheduler.advanceUntilIdle()
        TestCase.assertEquals(Cell.Character('H'), sut.display.lines[0].cells[0].value)
        TestCase.assertEquals(Cell.Character(' '), sut.display.lines[0].cells[5].value)
        TestCase.assertEquals(Cell.Character('d'), sut.display.lines[0].cells[10].value)
        TestCase.assertEquals(Cell.Cursor, sut.display.lines[0].cells[11].value)
    }

    @Test
    fun `insertText handles newlines`() = runTest {
        // given
        val keyboardController = KeyboardController()
        val sut = DisplayViewModel()
        sut.startListeningToKeyboard(keyboardController, StandardTestDispatcher(testScheduler))
        testScheduler.advanceUntilIdle()

        // when
        sut.setText("abc")
        keyboardController.insertText("\ndef")

        // then
        testScheduler.advanceUntilIdle()
        TestCase.assertEquals(Cell.Blank, sut.display.lines[0].cells[3].value)
        TestCase.assertEquals(Cell.Character('d'), sut.display.lines[1].cells[0].value)
        TestCase.assertEquals(Cell.Character('e'), sut.display.lines[1].cells[1].value)
        TestCase.assertEquals(Cell.Character('f'), sut.display.lines[1].cells[2].value)
        TestCase.assertEquals(Cell.Cursor, sut.display.lines[1].cells[3].value)
    }

    @Test
    fun `insertText ignores non ASCII characters`() = runTest {
        // given
        val keyboardController = KeyboardController()
        val sut = DisplayViewModel()
        sut.startListeningToKeyboard(keyboardController, StandardTestDispatcher(testScheduler))
        testScheduler.advanceUntilIdle()

        // when
        sut.setText("ab")
        keyboardController.insertText("😀cd")

        // then
        testScheduler.advanceUntilIdle()
        TestCase.assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        TestCase.assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        TestCase.assertEquals(Cell.Character('c'), sut.display.lines[0].cells[2].value)
        TestCase.assertEquals(Cell.Character('d'), sut.display.lines[0].cells[3].value)
        TestCase.assertEquals(Cell.Cursor, sut.display.lines[0].cells[4].value)
    }

    @Test
    fun `deleteBackward removes character`() = runTest {
        // given
        val keyboardController = KeyboardController()
        val sut = DisplayViewModel()
        sut.startListeningToKeyboard(keyboardController, StandardTestDispatcher(testScheduler))
        testScheduler.advanceUntilIdle()

        // when
        sut.setText("abc")
        keyboardController.deleteBackward()

        // then
        testScheduler.advanceUntilIdle()
        TestCase.assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        TestCase.assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        TestCase.assertEquals(Cell.Cursor, sut.display.lines[0].cells[2].value)
    }

    @Test
    fun `deleteBackward removes all characters`() = runTest {
        // given
        val keyboardController = KeyboardController()
        val sut = DisplayViewModel()
        sut.startListeningToKeyboard(keyboardController, StandardTestDispatcher(testScheduler))
        testScheduler.advanceUntilIdle()

        // when
        sut.setText("abc")
        keyboardController.deleteBackward()
        keyboardController.deleteBackward()
        keyboardController.deleteBackward()

        // then
        testScheduler.advanceUntilIdle()
        TestCase.assertEquals(Cell.Cursor, sut.display.lines[0].cells[0].value)
    }

    @Test
    fun `deleteBackward across newline`() = runTest {
        // given
        val keyboardController = KeyboardController()
        val sut = DisplayViewModel()
        sut.startListeningToKeyboard(keyboardController, StandardTestDispatcher(testScheduler))
        testScheduler.advanceUntilIdle()

        // when
        sut.setText("abc\ndef")
        keyboardController.deleteBackward()
        keyboardController.deleteBackward()
        keyboardController.deleteBackward()
        keyboardController.deleteBackward()

        // then
        testScheduler.advanceUntilIdle()
        TestCase.assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        TestCase.assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        TestCase.assertEquals(Cell.Character('c'), sut.display.lines[0].cells[2].value)
        TestCase.assertEquals(Cell.Cursor, sut.display.lines[0].cells[3].value)
        TestCase.assertEquals(Cell.Blank, sut.display.lines[1].cells[0].value)
    }

    @Test
    fun `deleteBackward removes newline`() = runTest {
        // given
        val keyboardController = KeyboardController()
        val sut = DisplayViewModel()
        sut.startListeningToKeyboard(keyboardController, StandardTestDispatcher(testScheduler))
        testScheduler.advanceUntilIdle()

        // when
        sut.setText("abc\n")
        keyboardController.deleteBackward()

        // then
        testScheduler.advanceUntilIdle()
        TestCase.assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        TestCase.assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        TestCase.assertEquals(Cell.Character('c'), sut.display.lines[0].cells[2].value)
        TestCase.assertEquals(Cell.Cursor, sut.display.lines[0].cells[3].value)
    }
}