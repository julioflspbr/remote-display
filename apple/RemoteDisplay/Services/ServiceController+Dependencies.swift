//
//  ServiceController+Live.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 14/09/2026.
//

extension ServiceController {
	@ServiceActor
	struct Dependencies {
		typealias ConcurrencyContext = (@Sendable @escaping () async throws -> Void) -> Void
		let builtInServices: [any Services.Service]
		let task: ConcurrencyContext
		let autoConnect: Bool?
	}
}

@ServiceActor
extension ServiceController.Dependencies {
	static let live = ServiceController.Dependencies(
		builtInServices: [
			Services.SmokeService(name: "Simulated Service LALA"),
			Services.SmokeService(name: "Simulated Service LONES")
		],
		task: { operation in
			Task(operation: operation)
		},
		autoConnect: nil
	)
}
