//
//  ErrorWithActions.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 15/10/2026.
//

import Foundation

enum Alert {
	@MainActor
	struct Action: Sendable, @MainActor Identifiable {
		enum Style {
			case highlighted
			case `default`
		}

		let title: LocalizedStringResource
		let style: Style
		let action: () async -> Void

		// conformance to Identifiable
		var id: String { title.key }

		init(title: LocalizedStringResource, style: Style = .default, action: sending @escaping () async -> Void = {}) {
			self.title = title
			self.style = style
			self.action = action
		}
	}

	protocol ErrorWithActions: Error {
		var actions: [Action] { get }
	}
}
