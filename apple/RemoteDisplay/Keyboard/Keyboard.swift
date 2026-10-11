//
//  Keyboard.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 01/09/2026.
//

import Foundation

enum Keyboard {
	enum Action {
		case text(String)
		case backspace
	}

	@MainActor
	protocol Service: AnyObject {
		func showKeyboard()
		func hideKeyboard()
	}
}
