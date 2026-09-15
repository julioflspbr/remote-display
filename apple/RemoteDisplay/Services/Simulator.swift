//
//  Simulator.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 12/09/2026.
//

#if DEBUG

import Foundation

extension Services {
	@ServiceActor
	final class Simulator: Service {
		private enum Specs {
			static let maxConnectionTime: Int = 5 // secs
			static let timeoutLimit: Duration = .seconds(4) // smaller than max to simulate timeout
		}

		struct SimulationError: LocalizedError {
			let message: LocalizedStringResource

			var errorDescription: String? {
				String(localized: self.message)
			}
		}

		init(name: String) {
			self.name = name
		}

		let name: String // for logging and debugging purposes

		@Persist(key: "services.simulator.failSearch")
		var simulateSearchFailure = false
		@Persist(key: "services.simulator.failConnection")
		var simulateConnectionFailure = false
		@Persist(key: "services.simulator.failDisconnection")
		var simulateDisconnectionFailure = false

		weak var delegate: ServiceDelegate?

		private(set) var status: Services.Status = .unavailable {
			didSet {
				self.delegate?.serviceDidUpdateStatus(self)
			}
		}

		func search() async throws {
			guard self.status == .unavailable else {
				return
			}
			do {
				self.status = .searching
				try await withTimeout(Specs.timeoutLimit) { @ServiceActor @Sendable in
					try await self.simulateWork()
					if self.simulateSearchFailure {
						throw SimulationError(message: .simulationServiceSearchFailure)
					}
				}
				self.status = .available
			} catch {
				self.status = .unavailable
				throw error
			}
		}

		func connect() async throws {
			if self.status == .unavailable {
				try await self.search()
			}
			guard self.status == .available else {
				return
			}
			do {
				self.status = .connecting
				try await withTimeout(Specs.timeoutLimit) { @ServiceActor @Sendable in
					try await self.simulateWork()
					if self.simulateConnectionFailure {
						throw SimulationError(message: .simulationServiceConnectionFailure)
					}
				}
				self.status = .connected
			} catch {
				self.status = .failure(error)
				throw error
			}
		}

		func disconnect() async throws {
			guard self.status == .connected else {
				return
			}
			do {
				self.status = .disconnecting
				try await withTimeout(Specs.timeoutLimit) { @ServiceActor @Sendable in
					try await self.simulateWork()
					if self.simulateDisconnectionFailure {
						throw SimulationError(message: .simulationServiceDisconnectionFailure)
					}
				}
				self.status = .disconnected
			} catch {
				self.status = .failure(error)
				throw error
			}
		}

		private func simulateWork() async throws {
			let workPeriod: Int = .random(in: 0...Specs.maxConnectionTime)
			try await Task.sleep(for: .seconds(workPeriod))
		}
	}
}
#endif
