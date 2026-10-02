//
//  PreviewService.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 29/09/2026.
//

#if DEBUG

import SwiftUI

extension Services {
	final class PreviewService: Identifiable, @unchecked Sendable {
		let id: Int
		let icon: Image
		var status: Services.Status

		init(id: Int, icon: Image, status: Services.Status = .unavailable) {
			self.id = id
			self.icon = icon
			self.status = status
		}
	}
}

extension Services.PreviewService: Services.Service {
	func search() async throws {
	}

	func connect() async throws {
	}

	func disconnect() async throws {
	}
}

extension Services.PreviewService: Hashable {
	static func == (lhs: Services.PreviewService, rhs: Services.PreviewService) -> Bool {
		lhs.id == rhs.id && lhs.icon == rhs.icon && lhs.status == rhs.status
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}

#endif
