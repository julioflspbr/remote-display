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
		let id: String
		let icon: Image
		let status: Services.Status
	}

	private var _services: [String: DisplayService] = [:]
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

	func callToAction(for service: DisplayService) {
//		switch service.status {
//			case .unavailable:
//				<#code#>
//			case .searching:
//				<#code#>
//			case .available:
//				<#code#>
//			case .connecting:
//				<#code#>
//			case .connected:
//				<#code#>
//			case .disconnecting:
//				<#code#>
//			case .disconnected:
//				<#code#>
//			case .failure(let error):
//				<#code#>
//		}
	}
}

extension ServicesViewModel: Services.ServiceDelegate {
	func serviceDidUpdateStatus(_ service: any Services.Service) {
		if let service = service as? any Services.ServiceWithIcon {
			Task { @MainActor in
				await _services[service.id] = DisplayService(id: service.id, icon: service.icon, status: service.status)
			}
		}
	}
}

private extension Services.ServiceWithIcon {
	func toDisplay() -> ServicesViewModel.DisplayService {
		ServicesViewModel.DisplayService(id: id, icon: icon, status: status)
	}
}
