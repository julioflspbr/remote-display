//
//  AlertController.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 11/10/2026.
//

import Foundation

actor AlertController {
	private var cache = [any Error]()
	private let streamer = MulticastStreamer<any Error>()

	var errors: AsyncStream<any Error> {
		let stream = self.streamer.makeStream()
		while let error = cache.first {
			self.streamer.send(error)
			cache.removeFirst()
		}
		return stream
	}

	func handle(error: any Error) {
		if !self.streamer.send(error) {
			cache.append(error)
		}
	}
}

extension AlertController: @MainActor Equatable {
	static func == (lhs: AlertController, rhs: AlertController) -> Bool {
		lhs === rhs
	}
}
