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
	protocol Controller: Sendable, AnyObject {
		var canShowKeyboard: Bool { get set }
		func insertText(_ text: String)
		func deleteBackward()
		func toggleKeyboard()
		func setService(_ service: any Service)
		func subscribe(client: any Client)
		func unsubscribe(clientID: UUID)
	}

	@MainActor
	protocol Service: AnyObject {
		func showKeyboard()
		func hideKeyboard()
	}

	@MainActor
	protocol Client: Sendable, Identifiable where ID == UUID {
		func receive(action: Keyboard.Action)
	}
}
