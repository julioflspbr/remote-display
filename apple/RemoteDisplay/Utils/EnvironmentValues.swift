//
//  EnvironmentValues.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 28/09/2026.
//

import SwiftUI

struct KeyboarControllerKey: EnvironmentKey {
	static let defaultValue: KeyboardController? = nil
}

struct ServiceControllerKey: EnvironmentKey {
	static let defaultValue: ServiceController? = nil
}

extension EnvironmentValues {
	var keyboardController: KeyboardController? {
		get { self[KeyboarControllerKey.self] }
		set { self[KeyboarControllerKey.self] = newValue }
	}

	var serviceController: ServiceController? {
		get { self[ServiceControllerKey.self] }
		set { self[ServiceControllerKey.self] = newValue }
	}
}
