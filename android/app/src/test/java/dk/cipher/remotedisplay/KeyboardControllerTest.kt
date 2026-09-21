package dk.cipher.remotedisplay

import dk.cipher.remotedisplay.keyboard.Keyboard
import dk.cipher.remotedisplay.keyboard.KeyboardController
import junit.framework.TestCase
import org.junit.Test

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

    private class MockKeyboardClient: Keyboard.Client {
        var actions = mutableListOf<Keyboard.Action>()

        override fun receive(action: Keyboard.Action) {
            actions.add(action)
        }
    }
}