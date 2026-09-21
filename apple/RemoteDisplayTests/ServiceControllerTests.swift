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
	@Test("empty built-in services throw No Built-in Service error")
	func throwErrorWhenNoBuiltInServices() {
		#expect(throws: Services.ServiceController.NoBuiltInServiceError.self) {
			try Services.ServiceController(dependencies: .mock())
		}
	}

	@Test("no auto-connect does not trigger search and connection")
	func noAutoConnect() async throws {
		// given
		var hasAutoConnectRun = false
		let operation: Services.ServiceController.Dependencies.ConcurrencyContext = { operation in
			hasAutoConnectRun = true
		}

		// when
		_ = try Services.ServiceController(dependencies: .mock([MockService(name: "unused")], operation, false))

		// then
		#expect(!hasAutoConnectRun, "The controller should not start auto connection")
	}

	@Test("run auto-connect procedure")
	func runAutoConnect() async throws {
		// given
		var task: Task<Void, Error>!
		let operation: Services.ServiceController.Dependencies.ConcurrencyContext = { operation in
			task = Task(operation: operation)
		}
		let unreachableService = MockService(name: "unreachable")
		let reachableService = MockService(name: "reachable")
		unreachableService.isReachable = false

		// when
		_ = try Services.ServiceController(dependencies: .mock([unreachableService, reachableService], operation, true))
		_ = try await task.value

		// then
		#expect(unreachableService.wasSearchCalled, "The service should have started auto search")
		#expect(reachableService.wasSearchCalled, "The service should have started auto search")
		#expect(!unreachableService.wasConnectCalled, "The service is not available, therefore should not connect")
		#expect(reachableService.wasConnectCalled, "The service should have started auto connect")
	}

	@Test("search and find all available services")
	func searchAndFindAllAvailableServices() async throws {
		// given
		let sut = try Services.ServiceController(dependencies: .mock([
			MockService(name: "A"), MockService(name: "B")
		]))

		// when
		let result = await sut.search().reduce(into: [MockService]()) { @Sendable result, service in
			result.append(service as! MockService)
		}

		// then
		#expect(result.count == 2, "There should be 2 services")
		#expect(result.allSatisfy { service in service.status == .available }, "All services should be available")
		#expect(sut.status == .available, "The Service Controller should mark itself as available, since at least one service is available")
	}

	@Test("controller is available when there is at least one available service")
	func controllerIsAvailable() async throws {
		// given
		let serviceA = MockService(name: "A")
		let serviceB = MockService(name: "B")
		let sut = try Services.ServiceController(dependencies: .mock([serviceA, serviceB]))

		// when
		serviceA.isReachable = true
		serviceB.isReachable = false
		_ = await sut.search().reduce(into: ()) { @Sendable _,_ in }

		// then
		#expect(sut.status == .available, "The Service Controller should mark itself as available, since at least one service is available")
	}

	@Test("controller is unavailable when there are no available services")
	func controllerIsUnavailable() async throws {
		// given
		let serviceA = MockService(name: "A")
		let serviceB = MockService(name: "B")
		let sut = try Services.ServiceController(dependencies: .mock([serviceA, serviceB]))

		// when
		serviceA.isReachable = false
		serviceB.isReachable = false
		_ = await sut.search().reduce(into: ()) { @Sendable _,_ in }

		// then
		#expect(sut.status == .unavailable, "The Service Controller should mark itself as unavailable, since no service is available")
	}

	@Test("connecting to the chosen service")
	func connectToChosenService() async throws {
		// given
		let serviceA = MockService(name: "A")
		let serviceB = MockService(name: "B")
		let sut = try Services.ServiceController(dependencies: .mock([serviceA, serviceB]))
		serviceA.controller = sut
		serviceB.controller = sut

		// when
		_ = try sut.selectNextService()
		try await sut.connect()

		// then
		#expect(sut.status == .connected)
		#expect(serviceA.status == .unavailable)
		#expect(serviceB.status == .connecting)
	}

	@Test("select the next service when not connected")
	func selectNextServiceWhenNotConnected() throws {
		// given
		let serviceA = MockService(name: "A")
		let serviceB = MockService(name: "B")
		let sut = try Services.ServiceController(dependencies: .mock([serviceA, serviceB]))
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

	@Test("select the next service should fail because there is one service connected")
	func selectNextServiceWhenConnected() async throws {
		// given
		let mockService = MockService(name: "A")
		let sut = try Services.ServiceController(dependencies: .mock([mockService]))

		// when
		try await sut.connect()

		// then
		#expect(throws: Services.ServiceController.ChangeServiceWhileConnectedError(), "The service should not be changed while connected") {
			_ = try sut.selectNextService()
		}
	}

	@Test("select the next service when not connected")
	func selectFirstServiceWhenNotConnected() throws {
		// given
		let serviceA = MockService(name: "A")
		let serviceB = MockService(name: "B")
		let sut = try Services.ServiceController(dependencies: .mock([serviceA, serviceB]))
		var current = try sut.selectNextService()

		// when
		current = try sut.selectFirstService()

		// then
		#expect(current === serviceA, "The first service should be returned")
	}

	@Test("select the first service should fail because there is one service connected")
	func selectFirstServiceWhenConnected() async throws {
		// given
		let mockService = MockService(name: "A")
		let sut = try Services.ServiceController(dependencies: .mock([mockService]))

		// when
		try await sut.connect()

		// then
		#expect(throws: Services.ServiceController.ChangeServiceWhileConnectedError(), "The service should not be changed while connected") {
			_ = try sut.selectFirstService()
		}
	}

	@Test("disconnecting the current service")
	func disconnectFromCurrentService() async throws {
		// given
		let mockService = MockService(name: "A")
		let sut = try Services.ServiceController(dependencies: .mock([mockService]))
		mockService.controller = sut

		// when
		try await sut.disconnect()

		// then
		#expect(sut.status == .disconnected)
		#expect(mockService.status == .disconnecting)
	}
}

private extension Services.ServiceController.Dependencies {
	static func mock(
		_ builtInServices: [any Services.Service] = [],
		_ task: @escaping (sending @escaping () async throws -> Void) -> Void = { @Sendable _ in },
		_ autoConnect: Bool? = nil
	) -> Self {
		Self(builtInServices: builtInServices, task: task, autoConnect: autoConnect)
	}
}

private final class MockService: Services.Service {
	let name: String
	var isReachable = true
	weak var controller: Services.ServiceController?

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
}
