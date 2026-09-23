//
//  ServiceController.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 14/09/2026.
//

extension Services {
	@ServiceActor
	final class ServiceController {
		let builtIn: [any Service]

		@Persist(key: "services.simulator.autoConnect")
		var autoConnect = false

		private(set) var status: Services.Status = .unavailable

		private var currentIndex = 0

		init(dependencies: Dependencies) throws {
			self.builtIn = dependencies.builtInServices
			guard !self.builtIn.isEmpty else {
				throw NoBuiltInServiceError()
			}
			if let autoConnect = dependencies.autoConnect {
				self.autoConnect = autoConnect
			}
			if self.autoConnect {
				dependencies.task { @ServiceActor @Sendable in
					let services = self.search()
					if let firstAvailable = await services.firstAvailable {
						try await firstAvailable.connect()
					}
				}
			}
		}

		func search() -> AsyncStream<any Service> {
			AsyncStream { continuation in
				Task {
					// it's ok to swallow the error;
					// the consumer will check individual service statuses
					try await withThrowingTaskGroup(of: Void.self) { group in
						self.status = .searching
						for service in self.builtIn {
							group.addTask {
								try await ServiceActor.run {
									try await service.search()
									continuation.yield(service)

									if service.status == .available {
										self.status = .available
									}
								}
							}
						}

						try await group.waitForAll()
						if self.status != .available {
							self.status = .unavailable
						}
						continuation.finish()
					}
				}
			}
		}

		func connect() async throws {
			self.status = .connecting
			try await self.builtIn[self.currentIndex].connect()
			self.status = .connected
		}

		@discardableResult
		func selectFirstService() throws -> any Service {
			guard self.status != .connecting && self.status != .connected else {
				throw ChangeServiceWhileConnectedError()
			}

			self.currentIndex = 0
			return self.builtIn[self.currentIndex]
		}

		@discardableResult
		func selectNextService() throws -> (any Service)? {
			guard self.status != .connecting && self.status != .connected else {
				throw ChangeServiceWhileConnectedError()
			}

			guard self.currentIndex < self.builtIn.count - 1 else {
				return nil
			}

			self.currentIndex += 1
			return self.builtIn[self.currentIndex]
		}

		func disconnect() async throws {
			self.status = .disconnecting
			try await self.builtIn[self.currentIndex].disconnect()
			self.status = .disconnected
		}
	}
}

private extension AsyncStream where Element == any Services.Service {
	var firstAvailable: Element? {
		get async {
			await first { @ServiceActor service in
				service.status == .available
			}
		}
	}
}
