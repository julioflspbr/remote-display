package dk.cipher.remotedisplay.display

import dk.cipher.remotedisplay.keyboard.Controller
import dk.cipher.remotedisplay.keyboard.Forwarder
import dk.cipher.remotedisplay.models.Cell
import dk.cipher.remotedisplay.views.display.DisplayViewModel
import dk.cipher.remotedisplay.views.display.DisplayViewModel.Dependencies.Subscription
import org.junit.Test
import junit.framework.TestCase.assertEquals
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.TestCoroutineScheduler
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.runTest

class DisplayViewModelTest {
    @Test
    fun `setText displays characters`() {
        val sut = DisplayViewModel(makeMockOfDisplayViewModelDependencies())

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
        val sut = DisplayViewModel(makeMockOfDisplayViewModelDependencies())

        sut.setText("abc")

        assertEquals(Cell.Cursor, sut.display.lines[0].cells[3].value)
    }

    @Test
    fun `setText handles newlines`() {
        val sut = DisplayViewModel(makeMockOfDisplayViewModelDependencies())

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
        val sut = DisplayViewModel(makeMockOfDisplayViewModelDependencies())

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
        val sut = DisplayViewModel(makeMockOfDisplayViewModelDependencies())

        sut.setText("a😀b")

        assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[2].value)
    }

    @Test
    @OptIn(ExperimentalCoroutinesApi::class)
    fun `insertText appends characters`() = runTest {
        val keyboard = Controller()
        val sut = DisplayViewModel(
            makeMockOfDisplayViewModelDependencies(
                keyboard,
                makeKeyEventSubscriptionContext(testScheduler)
            )
        )

        advanceUntilIdle()
        sut.setText("Hello")
        keyboard.insertText(" world")
        keyboard.endChannel()
        advanceUntilIdle()

        assertEquals(Cell.Character('H'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character(' '), sut.display.lines[0].cells[5].value)
        assertEquals(Cell.Character('d'), sut.display.lines[0].cells[10].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[11].value)
    }

    @Test
    @OptIn(ExperimentalCoroutinesApi::class)
    fun `insertText handles newlines`() = runTest {
        val keyboard = Controller()
        val sut = DisplayViewModel(
            makeMockOfDisplayViewModelDependencies(
                keyboard,
                makeKeyEventSubscriptionContext(testScheduler)
            )
        )

        advanceUntilIdle()
        sut.setText("abc")
        keyboard.insertText("\ndef")
        keyboard.endChannel()
        advanceUntilIdle()

        assertEquals(Cell.Blank, sut.display.lines[0].cells[3].value)
        assertEquals(Cell.Character('d'), sut.display.lines[1].cells[0].value)
        assertEquals(Cell.Character('e'), sut.display.lines[1].cells[1].value)
        assertEquals(Cell.Character('f'), sut.display.lines[1].cells[2].value)
        assertEquals(Cell.Cursor, sut.display.lines[1].cells[3].value)
    }

    @Test
    @OptIn(ExperimentalCoroutinesApi::class)
    fun `insertText ignores non ASCII characters`() = runTest {
        val keyboard = Controller()
        val sut = DisplayViewModel(
            makeMockOfDisplayViewModelDependencies(
                keyboard,
                makeKeyEventSubscriptionContext(testScheduler)
            )
        )

        advanceUntilIdle()
        sut.setText("ab")
        keyboard.insertText("😀cd")
        keyboard.endChannel()
        advanceUntilIdle()

        assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        assertEquals(Cell.Character('c'), sut.display.lines[0].cells[2].value)
        assertEquals(Cell.Character('d'), sut.display.lines[0].cells[3].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[4].value)
    }

    @Test
    @OptIn(ExperimentalCoroutinesApi::class)
    fun `deleteBackward removes character`() = runTest {
        val keyboard = Controller()
        val sut = DisplayViewModel(
            makeMockOfDisplayViewModelDependencies(
                keyboard,
                makeKeyEventSubscriptionContext(testScheduler)
            )
        )

        advanceUntilIdle()
        sut.setText("abc")
        keyboard.deleteBackward()
        keyboard.endChannel()
        advanceUntilIdle()

        assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[2].value)
    }

    @Test
    @OptIn(ExperimentalCoroutinesApi::class)
    fun `deleteBackward removes all characters`() = runTest {
        val keyboard = Controller()
        val sut = DisplayViewModel(
            makeMockOfDisplayViewModelDependencies(
                keyboard,
                makeKeyEventSubscriptionContext(testScheduler)
            )
        )

        advanceUntilIdle()
        sut.setText("abc")
        keyboard.deleteBackward()
        keyboard.deleteBackward()
        keyboard.deleteBackward()
        keyboard.endChannel()
        advanceUntilIdle()

        assertEquals(Cell.Cursor, sut.display.lines[0].cells[0].value)
    }

    @Test
    @OptIn(ExperimentalCoroutinesApi::class)
    fun `deleteBackward across newline`() = runTest {
        val keyboard = Controller()
        val sut = DisplayViewModel(
            makeMockOfDisplayViewModelDependencies(
                keyboard,
                makeKeyEventSubscriptionContext(testScheduler)
            )
        )

        advanceUntilIdle()
        sut.setText("abc\ndef")
        keyboard.deleteBackward()
        keyboard.deleteBackward()
        keyboard.deleteBackward()
        keyboard.deleteBackward()
        keyboard.endChannel()
        advanceUntilIdle()

        assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        assertEquals(Cell.Character('c'), sut.display.lines[0].cells[2].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[3].value)
        assertEquals(Cell.Blank, sut.display.lines[1].cells[0].value)
    }

    @Test
    @OptIn(ExperimentalCoroutinesApi::class)
    fun `deleteBackward removes newline`() = runTest {
        val keyboard = Controller()
        val sut = DisplayViewModel(
            makeMockOfDisplayViewModelDependencies(
                keyboard,
                makeKeyEventSubscriptionContext(testScheduler)
            )
        )

        advanceUntilIdle()
        sut.setText("abc\n")
        keyboard.deleteBackward()
        keyboard.endChannel()
        advanceUntilIdle()

        assertEquals(Cell.Character('a'), sut.display.lines[0].cells[0].value)
        assertEquals(Cell.Character('b'), sut.display.lines[0].cells[1].value)
        assertEquals(Cell.Character('c'), sut.display.lines[0].cells[2].value)
        assertEquals(Cell.Cursor, sut.display.lines[0].cells[3].value)
    }

    @OptIn(ExperimentalCoroutinesApi::class)
    private fun makeMockOfDisplayViewModelDependencies(
        keyEvents: Forwarder = Controller(),
        keyEventSubscriptionContext: Subscription = { operation ->
            CoroutineScope(UnconfinedTestDispatcher()).launch { operation() }
        }
    ) = DisplayViewModel.Dependencies(keyEvents, keyEventSubscriptionContext)

    private fun makeKeyEventSubscriptionContext(scheduler: TestCoroutineScheduler): Subscription = { operation ->
        CoroutineScope(StandardTestDispatcher(scheduler)).launch { operation() }
    }
}