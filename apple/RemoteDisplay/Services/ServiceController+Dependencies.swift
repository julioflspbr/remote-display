//
//  ServiceController+Live.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 14/09/2026.
//

extension Services.ServiceController {
	struct Dependencies {
		typealias ConcurrencyContext = (sending @escaping () async throws -> Void) -> Void
		let builtInServices: [any Services.Service]
		let task: ConcurrencyContext
		let autoConnect: Bool?
	}
}

@ServiceActor
extension Services.ServiceController.Dependencies {
	static let live = Services.ServiceController.Dependencies(
		builtInServices: [
			Services.Simulator(name: "Simulated Service LALA"),
			Services.Simulator(name: "Simulated Service LONES")
		],
		task: { operation in
			Task(operation: operation)
		},
		autoConnect: nil
	)
}
