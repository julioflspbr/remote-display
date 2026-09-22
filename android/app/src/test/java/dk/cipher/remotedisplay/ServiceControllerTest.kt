package dk.cipher.remotedisplay

import androidx.test.core.app.ApplicationProvider
import dk.cipher.remotedisplay.services.ServiceController
import dk.cipher.remotedisplay.services.Services
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ServiceControllerTest {
    @Test
    fun `empty built-in services throw No Built-in Service error`() {
        assertThrows(Services.NoBuiltInServiceError::class.java) {
            ServiceController(buildServiceControllerDependencies())
        }
    }

    @Test
    fun `no auto-connect does not trigger search and connection`() {
        // given
        var hasAutoConnectRun = false
        val operation: ServiceController.Dependencies.ConcurrencyContext = {
            hasAutoConnectRun = true
        }

        // when
        ServiceController(
            buildServiceControllerDependencies(
                listOf(MockService("unused")),
                operation,
                false
            )
        )

        // then
        assertFalse("The controller should not start auto connection", hasAutoConnectRun)
    }

    @OptIn(ExperimentalCoroutinesApi::class)
    @Test
    fun `run auto-connect procedure`() = runTest {
        // given
        val job = Job()
        val operation: ServiceController.Dependencies.ConcurrencyContext = { operation ->
            CoroutineScope(job + UnconfinedTestDispatcher()).launch {
                operation()
            }
            job.complete()
        }
        val unreachableService = MockService("unreachable")
        val reachableService = MockService("reachable")
        unreachableService.isReachable = false

        // when
        ServiceController(
            buildServiceControllerDependencies(
                listOf(unreachableService, reachableService),
                operation,
                true
            )
        )
        job.join()

        // then
        assertTrue("The service should have started auto search", unreachableService.wasSearchCalled)
        assertTrue("The service should have started auto search", reachableService.wasSearchCalled)
        assertFalse("The service is not available, therefore should not connect", unreachableService.wasConnectCalled)
        assertTrue("The service should have started auto connect", reachableService.wasConnectCalled)
    }

    @Test
    fun `search and find all available services`() = runTest {
        // given
        val sut = ServiceController(
            buildServiceControllerDependencies(
                listOf(MockService("A"), MockService("B"))
            )
        )

        // when
        val found = mutableListOf<Services.Service>()
        for (service in sut.search()) {
            found.add(service)
        }

        // then
        assertEquals("There should be 2 services", 2, found.size)
        assertTrue("All services should be available", found.all { it.status == Services.Status.Available })
        assertEquals("The Service Controller should mark itself as available, since at least one service is available", Services.Status.Available, sut.status)
    }

    @Test
    fun `controller is available when there is at least one available service`() = runTest {
        // given
        val searchedServices = mutableListOf<Services.Service>()
        val serviceA = MockService("A")
        val serviceB = MockService("B")
        val sut = ServiceController(
            buildServiceControllerDependencies(
                listOf(serviceA, serviceB)
            )
        )

        // when
        serviceA.isReachable = true
        serviceB.isReachable = false
        val services = sut.search()
        for (searched in services) {
            searchedServices.add(searched)
        }

        // then
        assertEquals("Two services were set as built-in, two services should've been searched", 2, searchedServices.size)
        assertEquals("The Service Controller should mark itself as available, since at least one service is available", Services.Status.Available, sut.status)
    }

    @Test
    fun `controller is unavailable when there are no available services`() = runTest {
        // given
        val searchedServices = mutableListOf<Services.Service>()
        val serviceA = MockService("A")
        val serviceB = MockService("B")
        val sut = ServiceController(
            buildServiceControllerDependencies(
                listOf(serviceA, serviceB)
            )
        )

        // when
        serviceA.isReachable = false
        serviceB.isReachable = false
        val services = sut.search()
        for (searched in services) {
            searchedServices.add(searched)
        }

        // then
        assertEquals("Two services were set as built-in, two services should've been searched", 2, searchedServices.size)
        assertEquals("The Service Controller should mark itself as unavailable, since no service is available", Services.Status.Unavailable, sut.status)
    }

    @Test
    fun `connecting to the chosen service`() = runTest {
        // given
        val serviceA = MockService("A")
        val serviceB = MockService("B")
        val sut = ServiceController(
            buildServiceControllerDependencies(
                listOf(serviceA, serviceB)
            )
        )
        serviceA.controller = sut
        serviceB.controller = sut

        // when
        val selected = sut.selectNextService()
        sut.connect()

        // then
        assertEquals("The Service B should be selected", serviceB, selected)
        // this is how we inspect the controller: the *mock service* statuses reflect what the *controller* was before becoming connected
        assertEquals("Service A is not selected, should be untouched", Services.Status.Unavailable, serviceA.status)
        assertEquals("Service B is selected, should be the one connecting", Services.Status.Connecting, serviceB.status)
    }

    @Test
    fun `select the next service when not connected`() {
        // given
        val serviceA = MockService("A")
        val serviceB = MockService("B")
        val sut = ServiceController(
            buildServiceControllerDependencies(
                listOf(serviceA, serviceB)
            )
        )

        // when
        var current = sut.selectNextService() as? MockService
        // then
        assertEquals("The next service was not correctly selected", "B", current?.name)

        // when
        current = sut.selectNextService() as? MockService
        // then
        assertNull("There is no next service available, so next service should return nil", current)
    }

    @Test
    fun `select the next service should fail because there is one service connected`() = runTest {
        // given
        val mockService = MockService("A")
        val sut = ServiceController(
            buildServiceControllerDependencies(
                listOf(mockService)
            )
        )

        // when
        sut.connect()

        // then
        assertThrows("The service should not be changed while connected", Services.ChangeServiceWhileConnectedError::class.java) {
            sut.selectNextService()
        }
    }

    @Test
    fun `select the first service`() {
        // given
        val serviceA = MockService("A")
        val serviceB = MockService("B")
        val sut = ServiceController(
            buildServiceControllerDependencies(
                listOf(serviceA, serviceB)
            )
        )
        sut.selectNextService()

        // when
        val result = sut.selectFirstService()

        // then
        assertEquals("The first service should be selected", serviceA, result)
    }

    @Test
    fun `select the first service should fail because there is one service connected`() = runTest {
        // given
        val mockService = MockService("A")
        val sut = ServiceController(
            buildServiceControllerDependencies(
                listOf(mockService)
            )
        )

        // when
        sut.connect()

        // then
        assertThrows("The service should not be changed while connected", Services.ChangeServiceWhileConnectedError::class.java) {
            sut.selectFirstService()
        }
    }

    @Test
    fun `disconnecting the current service`() = runTest {
        // given
        val mockService = MockService("A")
        val sut = ServiceController(
            buildServiceControllerDependencies(
                listOf(mockService)
            )
        )
        mockService.controller = sut

        // when
        sut.disconnect()

        // then
        assertEquals("The controller should be transitioned to disconnecting state before the disconnection", Services.Status.Disconnecting, mockService.status)
        assertEquals("The controller should set its status to disconnected after disconnection", Services.Status.Disconnected, sut.status)
    }

    private fun buildServiceControllerDependencies(
        builtInServices: List<Services.Service> = listOf(),
        task: (suspend () -> Unit) -> Unit = {},
        autoConnect: Boolean? = null)
    : ServiceController.Dependencies =
        ServiceController.Dependencies(
            builtInServices = builtInServices,
            context = ApplicationProvider.getApplicationContext(),
            task = task,
            autoConnect = autoConnect
        )
}

private class MockService(val name: String): Services.Service {
    var isReachable = true
    var controller: ServiceController? = null

    override var status: Services.Status = Services.Status.Unavailable
        private set
    var wasSearchCalled = false
        private set
    var wasConnectCalled = false

    override suspend fun search() {
        this.status = if (this.isReachable) Services.Status.Available else Services.Status.Unavailable
        this.wasSearchCalled = true
    }

    override suspend fun connect() {
        // status is repurposed for this test, to reflect the current
        // controller status right before the desired tested method is called
        this.status = this.controller?.status ?: Services.Status.Unavailable
        this.wasConnectCalled = true
    }

    override suspend fun disconnect() {
        // status is repurposed for this test, to reflect the current
        // controller status right before the desired tested method is called
        this.status = this.controller?.status ?: Services.Status.Unavailable
    }
}