//
//  App.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 17/08/2026.
//

import SwiftUI

@main
struct App: SwiftUI.App {
	@State private var keyboardController: KeyboardController?
	@State private var serviceController: ServiceController?
	@State private var alertController: AlertController?

	var body: some Scene {
		WindowGroup {
			ContentView()
				.task {
					self.serviceController = await Dependencies.serviceController()
				}
				.task {
					self.keyboardController = Dependencies.keyboardController()
				}
				.task {
					self.alertController = Dependencies.alertController()
				}
				.environment(\.keyboardController, keyboardController)
				.environment(\.serviceController, serviceController)
				.environment(\.alertController, alertController)
		}
	}
}
