//
//  DisplayViewModel+Dependencies.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 05/09/2026.
//

extension DisplayViewModel {
	@MainActor
	struct Dependencies {
		typealias Subscription = (@MainActor @Sendable @escaping () async -> Void) -> Task<Void, Never>

		let keyEvents: any Keyboard.Forwarder
		let keyEventSubscriptionContext: Subscription
	}
}

extension DisplayViewModel.Dependencies {
	static func live() -> Self {
		.init(
			keyEvents: Keyboard.Controller.shared,
			keyEventSubscriptionContext: { operation in
				Task<Void, Never>(operation: operation)
			}
		)
	}
}
