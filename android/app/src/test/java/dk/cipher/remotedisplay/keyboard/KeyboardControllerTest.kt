package dk.cipher.remotedisplay.keyboard

import dk.cipher.remotedisplay.keyboard.Keyboard.Action
import org.junit.Test
import junit.framework.TestCase.assertTrue
import junit.framework.TestCase.assertFalse
import junit.framework.TestCase.assertEquals

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
        assertTrue("The keyboard should be visible on first toggle", service.isKeyboardVisible)

        // when
        sut.toggleKeyboard()
        // then
        assertFalse("The keyboard should be hidden on second toggle", service.isKeyboardVisible)
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
        assertFalse("The keyboard should not be toggled when not allowed", service.isKeyboardVisible)
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
        assertTrue("The keyboard should be visible on first toggle", service.isKeyboardVisible)

        // when
        sut.canShowKeyboard = false
        assertFalse("The keyboard should be hidden when canShowKeyboard is set to false", service.isKeyboardVisible)
    }

    @Test
    fun `multiple subscribers receive the same actions and in sequence`() {
        // given
        val sut = KeyboardController()
        val client1 = MockKeyboardClient()
        val client2 = MockKeyboardClient()

        // when
        sut.subscribe(client1)
        sut.subscribe(client2)

        sut.insertText("ab")
        sut.insertText("c")
        sut.deleteBackward()
        sut.insertText("")
        sut.deleteBackward()

        // then
        val expectedActions = listOf(Action.Text("ab"), Action.Text("c"), Action.Backspace, Action.Backspace)
        assertEquals("Client 1 should receive the same actions in the same order", expectedActions, client1.actions)
        assertEquals("Client 2 should receive the same actions in the same order", expectedActions, client2.actions)
    }

    private class MockKeyboardService(var isKeyboardVisible: Boolean): Keyboard.Service {
        override fun showKeyboard() {
            this.isKeyboardVisible = true
        }

        override fun hideKeyboard() {
            this.isKeyboardVisible = false
        }
    }

    private class MockKeyboardClient: Keyboard.Client {
        var actions = mutableListOf<Action>()

        override fun receive(action: Action) {
            actions.add(action)
        }
    }
}