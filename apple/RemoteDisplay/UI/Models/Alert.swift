//
//  Alert.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 24/09/2026.
//

enum Alert {
	struct Action: Identifiable {
		let title: String
		let action: () -> Void
		let style: Style

		// conformance to Identifiable
		var id: String { title }

		init(title: String, style: Style = .default, action: @escaping () -> Void) {
			self.title = title
			self.action = action
			self.style = style
		}
	}

	enum Style {
		case highlighted
		case `default`
	}
}
