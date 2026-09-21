//
//  App+Dependencies.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 08/09/2026.
//

import Foundation

enum App {
	enum Controller {
		@MainActor
		static let keyboard = Keyboard.KeyboardController()

		@ServiceActor
		static let service: Services.ServiceController = {
			do {
				return try Services.ServiceController(dependencies: .live)
			} catch {
				fatalError(error.localizedDescription)
			}
		}()
	}
}
