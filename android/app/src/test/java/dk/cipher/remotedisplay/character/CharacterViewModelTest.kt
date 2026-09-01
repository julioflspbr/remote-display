package dk.cipher.remotedisplay.character

import dk.cipher.remotedisplay.views.character.CharacterViewModel
import org.junit.Test
import org.junit.Assert.assertTrue
import org.junit.Assert.assertFalse

class CharacterViewModelTest {
    @Test
    fun `test character blink`() {
        // given
        val blinkInterval: Long = 50
        val sut = CharacterViewModel(blinkInterval = blinkInterval)

        // when
        sut.blink()

        // then
        Thread.sleep(10) // just to put the blinker and test out of phase
        assertTrue("Blinking should start with cursor visible", sut.showCursor)

        Thread.sleep(blinkInterval)
        assertFalse("Blinking should hide cursor after the defined blink interval", sut.showCursor)

        Thread.sleep(blinkInterval)
        assertTrue("Blinking should show cursor after the defined blink interval", sut.showCursor)
    }

    @Test
    fun `test character steady`() {
        // given
        val blinkInterval: Long = 50
        val sut = CharacterViewModel(blinkInterval = blinkInterval)
        sut.blink()

        // when
        sut.steady()

        // then
        Thread.sleep(70) // wait out of phase
        assertFalse("Blinking should not change when calling steady", sut.showCursor)
    }
}