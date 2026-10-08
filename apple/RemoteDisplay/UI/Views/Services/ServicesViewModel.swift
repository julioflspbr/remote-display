//
//  ServicesViewModel.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 26/09/2026.
//

import SwiftUI

@Observable @MainActor
final class ServicesViewModel {
	struct DisplayService: Identifiable {
		let id: Int
		let icon: Image
		let status: Services.Status
	}

	private var _services: [Int: DisplayService] = [:]
	var services: [DisplayService] {
		Array(_services.values)
	}

	func setServiceController(_ controller: ServiceController?) async throws {
		guard let controller else {
			return
		}

		_services = await ServiceActor.run { @Sendable in
			let services: [DisplayService] = controller.builtIn.compactMap{ service in
				if let service = service as? any Services.ServiceWithIcon {
					service.toDisplay()
				} else {
					nil
				}
			}
			return Dictionary(uniqueKeysWithValues: zip(services.map(\.id), services))
		}
		await controller.setDelegate(self)
		try await controller.autoConnect()
	}
}

extension ServicesViewModel: Services.ServiceDelegate {
	func serviceDidUpdateStatus(_ service: any Services.Service) {
		if let service = service as? any Services.ServiceWithIcon {
			Task { @MainActor in
				_services[service.hashValue] = await DisplayService(id: service.hashValue, icon: service.icon, status: service.status)
			}
		}
	}
}

private extension Services.ServiceWithIcon {
	func toDisplay() -> ServicesViewModel.DisplayService {
		ServicesViewModel.DisplayService(id: hashValue, icon: icon, status: status)
	}
}
