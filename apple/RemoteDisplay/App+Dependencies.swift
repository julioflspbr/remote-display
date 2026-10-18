//
//  App+Dependencies.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 08/09/2026.
//

import Foundation

extension App {
	@MainActor
	enum Dependencies {
		static func keyboardController() -> KeyboardController {
			let keyboardController = KeyboardController()
			keyboardController.canShowKeyboard = true
			return keyboardController
		}

		static func serviceController() async -> ServiceController {
			await ServiceController(dependencies: .live)
		}

		static func alertController() -> AlertController {
			AlertController()
		}
	}
}
