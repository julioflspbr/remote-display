//
//  KeyboardForwarder.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 01/09/2026.
//

extension Keyboard {
	@MainActor
	protocol Forwarder: AnyObject {
		var keyboardAction: AsyncStream<Keyboard.Action> { get }
		func endActionStream()
	}
}
