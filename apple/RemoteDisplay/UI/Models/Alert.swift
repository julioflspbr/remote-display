//
//  Alert.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 24/09/2026.
//

import Foundation

struct Alert {
	let error: LocalizedError
	let actions: [Action]

	struct Action: Identifiable {
		enum Style {
			case highlighted
			case `default`
		}

		let title: LocalizedStringResource
		let action: () -> Void
		let style: Style

		// conformance to Identifiable
		var id: String { title.key }

		init(title: LocalizedStringResource, style: Style = .default, action: @escaping () -> Void) {
			self.title = title
			self.action = action
			self.style = style
		}
	}
}
