package dk.cipher.remotedisplay

import dk.cipher.remotedisplay.utils.MulticastChannel
import dk.cipher.remotedisplay.utils.Subscriber
import junit.framework.TestCase
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.Test

class MultiChannelTests {
    @OptIn(ExperimentalCoroutinesApi::class)
    @Test
    fun `channel cancels subscription upon release`() = runTest {
        // given
        val sut = MulticastChannel<Unit>()
        val client = Subscriber<Unit>()
        val job = client.subscribe(sut.makeChannel(), UnconfinedTestDispatcher(testScheduler))

        // when
        sut.close()

        // then
        job.join()
        // success, the test did not lock at await task.result
    }

    @Test
    fun `channel publishes values to multiple subscribers`() = runTest {
        // given
        val expected = listOf('a', 'b', 'c')
        val sut = MulticastChannel<Char>()
        val client1 = Subscriber<Char>()
        val client2 = Subscriber<Char>()
        val job1 = client1.subscribe(sut.makeChannel(), StandardTestDispatcher(testScheduler))
        val job2 = client2.subscribe(sut.makeChannel(), StandardTestDispatcher(testScheduler))

        // when
        sut.send('a')
        sut.send('b')
        sut.send('c')

        // then
        sut.close()
        job1.join()
        job2.join()

        TestCase.assertEquals("The elements were not received in client 1", expected, client1.accumulated)
        TestCase.assertEquals("The elements were not received in client 2", expected, client2.accumulated)
    }
}

