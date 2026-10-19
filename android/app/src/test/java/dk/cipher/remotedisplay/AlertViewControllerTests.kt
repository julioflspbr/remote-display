package dk.cipher.remotedisplay

import dk.cipher.remotedisplay.alert.AlertController
import dk.cipher.remotedisplay.utils.Subscriber
import junit.framework.TestCase
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.Test

class AlertViewControllerTests {
    @Test
    fun `errors marked as handled are streamed forward`() = runTest {
        // given
        val sut = AlertController()
        val subscriber = Subscriber<Throwable>()
        subscriber.subscribe(sut.errors(StandardTestDispatcher(testScheduler)), StandardTestDispatcher(testScheduler))

        // when
        sut.handle(MockError.Error1())
        sut.handle(MockError.Error2())
        sut.handle(MockError.Error3())

        // then
        TestCase.assertEquals("The collector did not catch the first error", subscriber.accumulated[0]::class, MockError.Error1::class)
        TestCase.assertEquals("The collector did not catch the second error", subscriber.accumulated[1]::class, MockError.Error2::class)
        TestCase.assertEquals("The collector did not catch the third error", subscriber.accumulated[2]::class, MockError.Error3::class)
    }

    @Test
    fun `errors accumulate before subscription and are sent after`() = runTest {
        // given
        val sut = AlertController()
        val subscriber = Subscriber<Throwable>()


        // when
        sut.handle(MockError.Error1())
        sut.handle(MockError.Error2())
        sut.handle(MockError.Error3())
        subscriber.subscribe(sut.errors(StandardTestDispatcher(testScheduler)), StandardTestDispatcher(testScheduler))

        // then
        testScheduler.advanceUntilIdle()
        TestCase.assertEquals("The collector did not catch the first error", subscriber.accumulated[0]::class, MockError.Error1::class)
        TestCase.assertEquals("The collector did not catch the second error", subscriber.accumulated[1]::class, MockError.Error2::class)
        TestCase.assertEquals("The collector did not catch the third error", subscriber.accumulated[2]::class, MockError.Error3::class)
    }
}

private sealed class MockError: Throwable() {
    class Error1: MockError()
    class Error2: MockError()
    class Error3: MockError()
}