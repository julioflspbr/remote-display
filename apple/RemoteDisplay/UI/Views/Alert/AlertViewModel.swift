//
//  AlertViewModel.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 09/10/2026.
//

import Foundation
import Observation

@Observable
final class AlertViewModel {
	private var currentAlert: Alert?

	var isAlerting: Bool {
		currentAlert != nil
	}

	var message: String {
		guard let currentAlert else {
			return ""
		}
		var message = currentAlert.error.localizedDescription
		if let recoverySuggestion = currentAlert.error.recoverySuggestion {
			message += "\n\(recoverySuggestion)"
		}
		return message
	}

	var actions: [Alert.Action] {
		guard let currentAlert else {
			return []
		}
		return currentAlert.actions.adjusted
	}

	init(initialAlert: Alert? = nil) {
		self.currentAlert = initialAlert
	}
}

private extension Array where Element == Alert.Action {
	var adjusted: Self {
		var adjusting = self
		var preselectedIndex: Int?

		for (i, action) in self.enumerated().reversed() {
			if preselectedIndex == nil && action.style == .highlighted {
				preselectedIndex = i
			} else if action.style == .highlighted {
				adjusting[i] = Element(
					title: action.title,
					style: .default,
					action: action.action
				)
			}
		}
		if let preselectedIndex {
			let preselected = adjusting.remove(at: preselectedIndex)
			adjusting.append(preselected)
		}
		return adjusting
	}
}
