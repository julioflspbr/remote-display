//
//  KeyboardResponder.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 22/08/2026.
//

import UIKit
import SwiftUI

extension View {
	func respondToKeyboard(insertText: @escaping (String) -> Void, deleteBackward: @escaping () -> Void) -> some View {
		modifier(KeyboardResponder(insertText: insertText, deleteBackward: deleteBackward))
	}
}

private struct KeyboardResponder: ViewModifier {
	let insertText: (String) -> Void
	let deleteBackward: () -> Void

	func body(content: Content) -> some View {
		content
			.overlay {
				KeyboardResponderOverlay(insertText: insertText, deleteBackward: deleteBackward)
			}
	}
}

private struct KeyboardResponderOverlay: UIViewRepresentable {
	let insertText: (String) -> Void
	let deleteBackward: () -> Void

	init(insertText: @escaping (String) -> Void, deleteBackward: @escaping () -> Void) {
		self.insertText = insertText
		self.deleteBackward = deleteBackward
	}

	func makeUIView(context: Context) -> KeyboardResponderView {
		KeyboardResponderView(insertText: insertText, deleteBackward: deleteBackward)
	}

	func updateUIView(_ uiView: KeyboardResponderView, context: Context) {
		// nothing to do
	}
}

private final class KeyboardResponderView: UIView, UIKeyInput {
	let hasText = true
	var keyboardType: UIKeyboardType = .asciiCapable

	private let insertTextCallback: (String) -> Void
	private let deleteBackwardCallback: () -> Void

	init(insertText: @escaping (String) -> Void, deleteBackward: @escaping () -> Void) {
		self.insertTextCallback = insertText
		self.deleteBackwardCallback = deleteBackward

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
		self.insertTextCallback(text)
	}

	func deleteBackward() {
		self.deleteBackwardCallback()
	}
}

