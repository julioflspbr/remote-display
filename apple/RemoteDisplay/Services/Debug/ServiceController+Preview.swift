//
//  ServiceController+Preview.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 29/09/2026.
//

#if DEBUG
import SwiftUI
import Synchronization

extension ServiceController {
	@MainActor
	static func preview(_ services: [(icon: Image, status: Services.Status)]) -> ServiceController {
		let semaphore = DispatchSemaphore(value: 0)
		let controllerMutex = Mutex<ServiceController?>(nil)
		DispatchQueue.global().async {
			Task { @Sendable in
				let controller = try await ServiceController(
					dependencies: .preview(
						services: services.enumerated().map { i, it in
							Services.PreviewService(id: i, icon: it.icon, status: it.status)
						}
					)
				)
				controllerMutex.withLock { it in it = controller }
				semaphore.signal()
			}
		}
		semaphore.wait()
		return controllerMutex.withLock { it in it! }
	}
}

private extension ServiceController.Dependencies {
	static func preview(services: [Services.PreviewService]) -> ServiceController.Dependencies {
		ServiceController.Dependencies(
			builtInServices: services,
			task: { _ in },
			autoConnect: nil
		)
	}
}

#endif
