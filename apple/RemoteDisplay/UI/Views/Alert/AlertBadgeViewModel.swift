//
//  AlertBadgeViewModel.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 22/10/2026.
//

import Observation

@Observable @MainActor
final class AlertBadgeViewModel {
	private(set) var isPressed = false
	private(set) var alertCount = 0

	@ObservationIgnored
	private var observationTask: Task<Void, Never>?

	#if DEBUG
	init(alertCount: Int = 0, isPressed: Bool = false) {
		self.alertCount = alertCount
		self.isPressed = isPressed
	}
	#endif

	func startListeningToAlertCount(in alertController: AlertController?) {
		self.stopListeningToAlertCount()

		guard let alertController else {
			return
		}
		self.observationTask = Task { [weak self] in
			for await count in await alertController.count {
				self?.alertCount = count
			}
		}
	}

	func stopListeningToAlertCount() {
		observationTask?.cancel()
		observationTask = nil
	}
}
