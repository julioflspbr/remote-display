package dk.cipher.remotedisplay.keyboard

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Semaphore
import kotlinx.coroutines.test.runTest

import org.junit.Test
import junit.framework.TestCase.assertEquals
import junit.framework.TestCase.assertTrue

class KeyboardControllerTest {
    @Test
    fun `test keyboard input`() = runTest {
        // given
        val semaphore = Semaphore(1)
        val sut = Controller()

        // when
        val collector = makeCollector(sut, semaphore)
        semaphore.acquire()
        CoroutineScope(Dispatchers.Default).launch {
            sut.insertText("ab")
            sut.insertText("c")
            sut.insertText("")
            sut.endChannel()
        }

        // then
        val result = collector.await()
        assertEquals("There were 2 valid text inputs, but the result does not contain 2 results", result.size, 2)
        assertEquals("The first input doesn't match the output", result[0], Action.Text("ab"))
        assertEquals("The first input doesn't match the output", result[1], Action.Text("c"))
    }

    @Test
    fun `test backspace`() = runTest {
        // given
        val semaphore = Semaphore(1)
        val sut = Controller()

        // when
        val collector = makeCollector(sut, semaphore)
        semaphore.acquire()
        CoroutineScope(Dispatchers.Default).launch {
            sut.deleteBackward()
            sut.deleteBackward()
            sut.deleteBackward()
            sut.endChannel()
        }

        // then
        val result = collector.await()
        assertEquals("There were 3 valid backspace inputs, but the result does not contain 3 results", result.size, 3)
        assertTrue("Not all the inputs were backspaces", result.all { it == Action.Backspace })
    }

    private fun makeCollector(sut: Controller, semaphore: Semaphore): Deferred<List<Action>> =
        CoroutineScope(Dispatchers.IO).async {
            val result = mutableListOf<Action>()
            semaphore.release()
            for (action in sut.keyboardAction) {
                result.add(action)
            }
            return@async result
        }
}