//
//  KeyboardReceiver.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 01/09/2026.
//

extension Keyboard {
	@MainActor
	protocol Receiver: AnyObject {
		func insertText(_ text: String)
		func deleteBackward()
	}
}
