package dk.cipher.remotedisplay

import dk.cipher.remotedisplay.keyboard.Keyboard
import dk.cipher.remotedisplay.keyboard.KeyboardController
import dk.cipher.remotedisplay.utils.ClosingChannel
import junit.framework.TestCase
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.runTest
import org.junit.Test
import kotlin.coroutines.CoroutineContext

class KeyboardControllerTest {
    @Test
    fun `toggle keyboard when controller allows it`() {
        // given
        val service = MockKeyboardService(false)
        val sut = KeyboardController()
        sut.setService(service)

        // when
        sut.canShowKeyboard = true
        sut.toggleKeyboard()
        // then
        TestCase.assertTrue(
            "The keyboard should be visible on first toggle",
            service.isKeyboardVisible
        )

        // when
        sut.toggleKeyboard()
        // then
        TestCase.assertFalse(
            "The keyboard should be hidden on second toggle",
            service.isKeyboardVisible
        )
    }

    @Test
    fun `controller does not allow keyboard toggling`() {
        // given
        val service = MockKeyboardService(false)
        val sut = KeyboardController()
        sut.setService(service)

        // when
        sut.canShowKeyboard = false
        sut.toggleKeyboard()

        // then
        TestCase.assertFalse(
            "The keyboard should not be toggled when not allowed",
            service.isKeyboardVisible
        )
    }

    @Test
    fun `canShoKeyboard automatically hides the keyboard when set to false`() {
        // given
        val service = MockKeyboardService(true)
        val sut = KeyboardController()
        sut.setService(service)

        // when
        sut.canShowKeyboard = true
        sut.toggleKeyboard()
        // then
        TestCase.assertTrue(
            "The keyboard should be visible on first toggle",
            service.isKeyboardVisible
        )

        // when
        sut.canShowKeyboard = false
        TestCase.assertFalse(
            "The keyboard should be hidden when canShowKeyboard is set to false",
            service.isKeyboardVisible
        )
    }

    @Test
    fun `multiple subscribers receive the same actions and in sequence`() = runTest {
        // given
        val sut = KeyboardController()
        val client1 = MockKeyboardClient(sut, StandardTestDispatcher(testScheduler))
        val client2 = MockKeyboardClient(sut, StandardTestDispatcher(testScheduler))
        testScheduler.advanceUntilIdle()

        // when
        sut.insertText("ab")
        sut.insertText("c")
        sut.deleteBackward()
        sut.insertText("")
        sut.deleteBackward()

        // then
        testScheduler.advanceUntilIdle()
        client1.thatsIt()
        client2.thatsIt()

        val expectedActions = listOf(Keyboard.Action.Text("ab"), Keyboard.Action.Text("c"), Keyboard.Action.Backspace, Keyboard.Action.Backspace)
        TestCase.assertEquals(
            "Client 1 should receive the same actions in the same order",
            expectedActions,
            client1.actions
        )
        TestCase.assertEquals(
            "Client 2 should receive the same actions in the same order",
            expectedActions,
            client2.actions
        )
    }

    private class MockKeyboardService(var isKeyboardVisible: Boolean): Keyboard.Service {
        override fun showKeyboard() {
            this.isKeyboardVisible = true
        }

        override fun hideKeyboard() {
            this.isKeyboardVisible = false
        }
    }

    private class MockKeyboardClient {
        var actions = mutableListOf<Keyboard.Action>()
            private set

        val actionStream: ClosingChannel<Keyboard.Action>

        constructor(keyboardController: KeyboardController, context: CoroutineContext) {
            this.actionStream = keyboardController.actions
            CoroutineScope(context).launch {
                for (action in actionStream) {
                    actions.add(action)
                }
            }
        }

        fun thatsIt() {
            this.actionStream.close()
        }
    }
}