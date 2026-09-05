//
//  KeyboardResponder.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 22/08/2026.
//

import UIKit
import SwiftUI

extension View {
	func respondToKeyboard(receiver: any Keyboard.Receiver = Keyboard.Controller.shared) -> some View {
		modifier(KeyboardResponder(receiver: receiver))
	}
}

private struct KeyboardResponder: ViewModifier {
	private(set) weak var receiver: (any Keyboard.Receiver)?

	func body(content: Content) -> some View {
		content
			.overlay {
				KeyboardResponderOverlay(receiver: receiver)
			}
	}
}

private struct KeyboardResponderOverlay: UIViewRepresentable {
	private(set) weak var receiver: (any Keyboard.Receiver)?

	func makeUIView(context: Context) -> KeyboardResponderView {
		KeyboardResponderView(receiver: receiver)
	}

	func updateUIView(_ uiView: KeyboardResponderView, context: Context) {
		// nothing to do
	}
}

private final class KeyboardResponderView: UIView, UIKeyInput {
	let hasText = true
	var keyboardType: UIKeyboardType = .asciiCapable

	private(set) var receiver: (any Keyboard.Receiver)?

	init(receiver: (any Keyboard.Receiver)?) {
		self.receiver = receiver
		super.init(frame: .zero)
	}

	required init?(coder: NSCoder) {
		fatalError("Not implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(didTap))
		self.addGestureRecognizer(tapGestureRecogniser)
	}

	override var canBecomeFirstResponder: Bool {
		true
	}

	@objc func didTap() {
		if self.isFirstResponder {
			self.resignFirstResponder()
		} else {
			self.becomeFirstResponder()
		}
	}

	func insertText(_ text: String) {
		self.receiver?.insertText(text)
	}

	func deleteBackward() {
		self.receiver?.deleteBackward()
	}
}

