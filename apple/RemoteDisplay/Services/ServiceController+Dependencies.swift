//
//  ServiceController+Live.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 14/09/2026.
//

extension ServiceController {
	@ServiceActor
	struct Dependencies {
		let builtInServices: [any Services.Service]
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
		autoConnect: nil
	)
}
