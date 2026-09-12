//
//  KeyboardResponder.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 22/08/2026.
//

import UIKit
import SwiftUI

extension View {
	func respondToKeyboard(controller: any Keyboard.Controller = App.keyboarController) -> some View {
		modifier(KeyboardResponder(controller: controller))
	}
}

private struct KeyboardResponder: ViewModifier {
	private(set) weak var controller: (any Keyboard.Controller)?

	func body(content: Content) -> some View {
		content
			.overlay {
				KeyboardResponderOverlay(controller: controller)
			}
	}
}

private struct KeyboardResponderOverlay: UIViewRepresentable {
	private(set) weak var controller: (any Keyboard.Controller)?

	func makeUIView(context: Context) -> KeyboardResponderView {
		KeyboardResponderView(controller: controller)
	}

	func updateUIView(_ uiView: KeyboardResponderView, context: Context) {
		// nothing to do
	}
}

private final class KeyboardResponderView: UIView, Keyboard.Service, UIKeyInput {
	let hasText = true
	var keyboardType: UIKeyboardType = .asciiCapable

	private(set) var controller: (any Keyboard.Controller)?

	init(controller: (any Keyboard.Controller)?) {
		self.controller = controller
		super.init(frame: .zero)
		self.controller?.setService(self)
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

