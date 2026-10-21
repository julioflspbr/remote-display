package dk.cipher.remotedisplay

import dk.cipher.remotedisplay.utils.ClosingChannel
import dk.cipher.remotedisplay.utils.Subscriber
import junit.framework.TestCase
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.Test

class ClosingChannelTests {
    @Test
    fun `onClose is called when the channel is closed`() {
        // given
        var onCloseCalled = false
        val channel = ClosingChannel<Unit> {
            onCloseCalled = true
        }

        // when
        channel.close()

        // then
        TestCase.assertTrue("The onClose callback was not called", onCloseCalled)
    }

    @Test
    fun `all elements are received in the same order`() = runTest {
        // given
        val channel = ClosingChannel<Int> { }
        val expected = listOf(1, 2, 3)
        val subscriber = Subscriber<Int>()
        subscriber.subscribe(channel, StandardTestDispatcher(testScheduler))

        // when
        channel.send(1)
        channel.send(2)
        channel.send(3)
        channel.close()

        // then
        testScheduler.advanceUntilIdle()
        TestCase.assertEquals("The elements were not received in the same order", expected, subscriber.accumulated)
    }
}