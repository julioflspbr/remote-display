//
//  KeyboardResponder.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 22/08/2026.
//

import UIKit
import SwiftUI

extension View {
	func respondToKeyboard(controller: KeyboardController?) -> some View {
		modifier(KeyboardResponder(controller: controller))
	}
}

private struct KeyboardResponder: ViewModifier {
	let controller: KeyboardController?

	func body(content: Content) -> some View {
		content
			.overlay {
				KeyboardResponderOverlay(controller: controller)
			}
	}
}

private struct KeyboardResponderOverlay: UIViewRepresentable {
	let controller: KeyboardController?

	func makeUIView(context: Context) -> KeyboardResponderView {
		KeyboardResponderView()
	}

	func updateUIView(_ view: KeyboardResponderView, context: Context) {
		view.controller = controller
	}
}

private final class KeyboardResponderView: UIView, Keyboard.Service, UIKeyInput {
	let hasText = true
	var keyboardType: UIKeyboardType = .asciiCapable

	weak var controller: KeyboardController? {
		didSet {
			self.controller?.setService(self)
		}
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
		self.controller?.toggleKeyboard()
	}

	func showKeyboard() {
		self.becomeFirstResponder()
	}

	func hideKeyboard() {
		self.resignFirstResponder()
	}

	func insertText(_ text: String) {
		self.controller?.insertText(text)
	}

	func deleteBackward() {
		self.controller?.deleteBackward()
	}
}

