//
//  RemoteDisplayApp.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 17/08/2026.
//

import SwiftUI

@main
struct RemoteDisplayApp: App {
	@State private var keyboardController: KeyboardController?
	@State private var serviceController: ServiceController?

	var body: some Scene {
		WindowGroup {
			ContentView()
				.task {
					self.serviceController = await Dependencies.serviceController()
				}
				.task {
					self.keyboardController = Dependencies.keyboardController()
				}
				.environment(\.keyboardController, keyboardController)
				.environment(\.serviceController, serviceController)
		}
	}
}
