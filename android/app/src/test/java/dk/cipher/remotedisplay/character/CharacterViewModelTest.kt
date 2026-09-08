package dk.cipher.remotedisplay.character

import dk.cipher.remotedisplay.views.character.CharacterViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.TestDispatcher
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.Test
import org.junit.Assert.assertTrue
import org.junit.Assert.assertFalse
import org.junit.Rule
import org.junit.rules.TestWatcher
import org.junit.runner.Description
import kotlin.time.Duration.Companion.milliseconds

class CharacterViewModelTest {
    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    @Test
    @OptIn(ExperimentalCoroutinesApi::class)
    fun `test character blink`() = runTest(mainDispatcherRule.testDispatcher.scheduler) {
        // given
        val blinkInterval = 50.milliseconds
        val sut = CharacterViewModel(blinkInterval = blinkInterval)

        // when
        sut.blink()

        // then
        advanceTimeBy(10.milliseconds) // just to put the blinker and test out of phase
        assertTrue("Blinking should start with cursor visible", sut.showCursor)

        advanceTimeBy(blinkInterval)
        assertFalse("Blinking should hide cursor after the defined blink interval", sut.showCursor)

        advanceTimeBy(blinkInterval)
        assertTrue("Blinking should show cursor after the defined blink interval", sut.showCursor)

        sut.steady()
    }

    @Test
    @OptIn(ExperimentalCoroutinesApi::class)
    fun `test character steady`() = runTest(mainDispatcherRule.testDispatcher.scheduler) {
        // given
        val blinkInterval = 50.milliseconds
        val sut = CharacterViewModel(blinkInterval = blinkInterval)
        sut.blink()

        // when
        sut.steady()

        // then
        advanceTimeBy(70.milliseconds) // wait out of phase
        assertFalse("Blinking should not change when calling steady", sut.showCursor)
    }
}

@OptIn(ExperimentalCoroutinesApi::class)
class MainDispatcherRule(val testDispatcher: TestDispatcher = StandardTestDispatcher()) : TestWatcher() {
    override fun starting(description: Description) {
        Dispatchers.setMain(testDispatcher)
    }

    override fun finished(description: Description) {
        Dispatchers.resetMain()
    }
}