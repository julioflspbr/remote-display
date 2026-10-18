//
//  AlertViewModel.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 09/10/2026.
//

import Foundation
import Observation

@MainActor @Observable
final class AlertViewModel {
	private let semaphore = TaskSemaphore()
	private var currentError: (any Error)?
	private var handlingTask: Task<Void, Never>?

	var isAlerting: Bool {
		currentError != nil
	}

	var message: String {
		guard let currentError else {
			return ""
		}
		var message = ""
		if let currentError = currentError as? LocalizedError {
			if let errorDescription = currentError.errorDescription {
				message += errorDescription
			}
			if let failureReason = currentError.failureReason {
				message += "\n\(failureReason)"
			}
			if let recoverySuggestion = currentError.recoverySuggestion {
				message += "\n\(recoverySuggestion)"
			}
		} else {
			message = currentError.localizedDescription
		}
		return message
	}

	var actions: [Alert.Action] {
		guard let currentError else {
			return []
		}
		if let currentError = currentError as? Alert.ErrorWithActions {
			let dismissingActions = currentError.actions.map { action in
				var dismissableAction = action
				dismissableAction.action = {
					await action.action()
					self.currentError = nil
					await self.semaphore.signal()
				}
				return dismissableAction
			}
			return dismissingActions.sorted
		} else {
			return [Alert.Action(title: .errorActionTitleOk, style: .highlighted)]
		}
	}

	func startListningToErrors(in alertController: AlertController?) {
		self.handlingTask?.cancel()

		guard let alertController else {
			return
		}
		self.handlingTask = Task {
			for await error in await alertController.errors {
				self.currentError = error
				await self.semaphore.wait()
			}
		}
	}

	func stopListeningToErrors() {
		self.handlingTask?.cancel()
	}

	#if DEBUG
	func setCurrentError(_ currentError: any Error) {
		self.currentError = currentError
	}
	#endif
}

@MainActor
private extension Array where Element == Alert.Action {
	var sorted: Self {
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
