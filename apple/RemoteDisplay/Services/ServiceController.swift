//
//  ServiceController.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 14/09/2026.
//

@ServiceActor
final class ServiceController {
	let builtIn: [String: any Services.Service]

	private let searchStream = Multicast.ThrowingStreamer<any Services.Service, any Swift.Error>()

	private(set) var status: Services.Status = .unavailable

	@Persist(key: "service.selected")
	private var selectedServiceName: String? = nil

	private var selectedService: (any Services.Service)? {
		get {
			guard let selectedServiceName else {
				return nil
			}
			return self.builtIn[selectedServiceName]
		}
		set {
			self.selectedServiceName = newValue?.id
		}
	}

	init(dependencies: Dependencies) {
		if dependencies.builtInServices.isEmpty {
			dependencies.noServicesErrorHandler()
		}
		self.builtIn = Dictionary(uniqueKeysWithValues: dependencies.builtInServices.map { service in
			(service.id, service)
		})
	}

	func autoConnect() async throws {
		guard let selectedService else {
			return
		}
		for try await service in self.search() {
			if service.id == selectedService.id {
				try await selectedService.connect()
				return
			}
		}
	}

	func search() -> Multicast.ThrowingStream<any Services.Service, any Swift.Error> {
		let isAlreadySearching = self.searchStream.isStreaming
		let newStream = self.searchStream.makeStream()
		if !isAlreadySearching {
			Task {
				do {
					try await withThrowingTaskGroup(of: Void.self) { group in
						self.status = .searching
						for service in self.builtIn.values {
							group.addTask {
								try await ServiceActor.run {
									try await service.search()
									self.searchStream.send(value: service)

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
						self.searchStream.finish()
					}
				} catch {
					self.searchStream.throw(error: error)
				}
			}
		}
		return newStream
	}

	func connect(to service: any Services.Service) async throws {
		self.status = .connecting
		self.selectedService = service
		try await self.selectedService?.connect()
		self.status = .connected
	}

	func disconnect() async throws {
		self.status = .disconnecting
		self.selectedService = nil
		try await self.selectedService?.disconnect()
		self.status = .disconnected
	}

	func setDelegate(_ delegate: any Services.ServiceDelegate) {
		for service in self.builtIn.values {
			service.setDelegate(delegate)
		}
	}
}

extension ServiceController: @ServiceActor Equatable {
	static func == (lhs: ServiceController, rhs: ServiceController) -> Bool {
		lhs === rhs
	}
}
