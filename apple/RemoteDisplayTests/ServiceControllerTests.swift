//
//  ServiceControllerTests.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 15/09/2026.
//

import Testing
import Foundation
@testable import RemoteDisplay

@Suite @ServiceActor
struct ServiceControllerTests {
	@Test
	func `empty built-in services halts the app execution`() {
		// given
		var hasHalted = false
		let noServiceErrorHandler: () -> Void = {
			hasHalted = true
		}

		// when
		_ = ServiceController(dependencies: .mock(noServiceErrorHandler: noServiceErrorHandler))

		// then
		#expect(hasHalted, "The controller should not allow initialisation without services")
	}

	@Test
	func `no auto-connect does not trigger search and connection`() async throws {
		// given
		let service = MockService(name: "service")

		// when
		let sut = ServiceController(dependencies: .mock([service], false))
		try await sut.autoConnect()

		// then
		#expect(!service.wasSearchCalled, "The controller should not auto search")
		#expect(!service.wasConnectCalled, "The controller should not start auto connection")
	}

	@Test
	func `run auto-connect procedure`() async throws {
		// given
		let unreachableService = MockService(name: "unreachable")
		let reachableService = MockService(name: "reachable")
		unreachableService.isReachable = false

		// when
		let sut = ServiceController(dependencies: .mock([unreachableService, reachableService], true))
		try await sut.autoConnect()

		// then
		#expect(unreachableService.wasSearchCalled, "The service should have started auto search")
		#expect(reachableService.wasSearchCalled, "The service should have started auto search")
		#expect(!unreachableService.wasConnectCalled, "The service is not available, therefore should not connect")
		#expect(reachableService.wasConnectCalled, "The service should have started auto connect")
	}

	@Test
	func `search and find all available services`() async throws {
		// given
		let sut = ServiceController(dependencies: .mock([
			MockService(name: "A"), MockService(name: "B")
		]))

		// when
		let result = try await sut.search().reduce(into: [MockService]()) { @Sendable result, service in
			result.append(service as! MockService)
		}

		// then
		#expect(result.count == 2, "There should be 2 services")
		#expect(result.allSatisfy { service in service.status == .available }, "All services should be available")
		#expect(sut.status == .available, "The Service Controller should mark itself as available, since at least one service is available")
	}

	@Test
	func `controller is available when there is at least one available service`() async throws {
		// given
		let serviceA = MockService(name: "A")
		let serviceB = MockService(name: "B")
		let sut = ServiceController(dependencies: .mock([serviceA, serviceB]))

		// when
		serviceA.isReachable = true
		serviceB.isReachable = false
		_ = try await sut.search().reduce(into: ()) { @Sendable _,_ in }

		// then
		#expect(sut.status == .available, "The Service Controller should mark itself as available, since at least one service is available")
	}

	@Test
	func `controller is unavailable when there are no available services`() async throws {
		// given
		let serviceA = MockService(name: "A")
		let serviceB = MockService(name: "B")
		let sut = ServiceController(dependencies: .mock([serviceA, serviceB]))

		// when
		serviceA.isReachable = false
		serviceB.isReachable = false
		_ = try await sut.search().reduce(into: ()) { @Sendable _,_ in }

		// then
		#expect(sut.status == .unavailable, "The Service Controller should mark itself as unavailable, since no service is available")
	}

	@Test
	func `connecting to the chosen service`() async throws {
		// given
		let serviceA = MockService(name: "A")
		let serviceB = MockService(name: "B")
		let sut = ServiceController(dependencies: .mock([serviceA, serviceB]))
		serviceA.controller = sut
		serviceB.controller = sut

		// when
		let selected = try sut.selectNextService()
		try await sut.connect()

		// then
		#expect(selected === serviceB, "The Service B should be selected")
		// this is how we inspect the controller: the *mock service* status reflect what the *controller* was before becoming connected
		#expect(serviceA.status == .unavailable, "Service A is not selected, should be untouched")
		#expect(serviceB.status == .connecting, "Service B is selected, should be the one connecting")
		#expect(sut.status == .connected)
	}

	@Test
	func `select the next service when not connected`() throws {
		// given
		let serviceA = MockService(name: "A")
		let serviceB = MockService(name: "B")
		let sut = ServiceController(dependencies: .mock([serviceA, serviceB]))
		var current: MockService?

		// when
		current = try sut.selectNextService() as? MockService
		// then
		#expect(current?.name == "B", "The next service was not correctly selected")

		// when
		current = try sut.selectNextService() as? MockService
		// then
		#expect(current == nil, "There is no next service available, so next service should return nil")
	}

	@Test
	func `select the next service should fail because there is one service connected`() async throws {
		// given
		let mockService = MockService(name: "A")
		let sut = ServiceController(dependencies: .mock([mockService]))

		// when
		try await sut.connect()

		// then
		#expect(throws: ServiceController.ChangeServiceWhileConnectedError.self, "The service should not be changed while connected") {
			try sut.selectNextService()
		}
	}

	@Test
	func `select the first service when not connected`() throws {
		// given
		let serviceA = MockService(name: "A")
		let serviceB = MockService(name: "B")
		let sut = ServiceController(dependencies: .mock([serviceA, serviceB]))
		var current = try sut.selectNextService()

		// when
		current = try sut.selectFirstService()

		// then
		#expect(current === serviceA, "The first service should be returned")
	}

	@Test
	func `select the first service should fail because there is one service connected`() async throws {
		// given
		let mockService = MockService(name: "A")
		let sut = ServiceController(dependencies: .mock([mockService]))

		// when
		try await sut.connect()

		// then
		#expect(throws: ServiceController.ChangeServiceWhileConnectedError.self, "The service should not be changed while connected") {
			try sut.selectFirstService()
		}
	}

	@Test
	func `disconnecting the current service`() async throws {
		// given
		let mockService = MockService(name: "A")
		let sut = ServiceController(dependencies: .mock([mockService]))
		mockService.controller = sut

		// when
		try await sut.disconnect()

		// then
		#expect(mockService.status == .disconnecting, "The controller should be transitioned to disconnecting state before the disconnection")
		#expect(sut.status == .disconnected, "The controller should set its status to disconnected after disconnection")
	}
}

private extension ServiceController.Dependencies {
	static func mock(
		_ builtInServices: [any Services.Service] = [],
		_ autoConnect: Bool? = nil,
		noServiceErrorHandler: @escaping () -> Void = { Issue.record("There is no service to test") }
	) -> Self {
		ServiceController.Dependencies(builtInServices: builtInServices, autoConnect: autoConnect, noServicesErrorHandler: noServiceErrorHandler)
	}
}

@ServiceActor
private final class MockService: Services.Service {
	let name: String
	var isReachable = true
	weak var controller: ServiceController?

	private(set) var status: Services.Status = .unavailable
	private(set) var wasSearchCalled = false
	private(set) var wasConnectCalled = false

	init(name: String) {
		self.name = name
	}

	func search() async throws {
		self.status = isReachable ? .available : .unavailable
		self.wasSearchCalled = true
	}
	
	func connect() async throws {
		// status is repurposed for this test, to reflect the current
		// controller status right before the desired tested method is called
		self.status = self.controller?.status ?? .unavailable
		self.wasConnectCalled = true
	}
	
	func disconnect() async throws {
		// status is repurposed for this test, to reflect the current
		// controller status right before the desired tested method is called
		self.status = self.controller?.status ?? .unavailable
	}

	nonisolated static func == (lhs: MockService, rhs: MockService) -> Bool {
		lhs.name == rhs.name
	}

	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}
}
