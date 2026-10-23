//
//  AlertController.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 11/10/2026.
//

import Foundation

actor AlertController {
	private let countStreamer = MulticastStreamer<Int>()
	private let errorStreamer = MulticastStreamer<any Error>()

	private var cache = [any Error]() {
		didSet {
			self.countStreamer.send(self.cache.count)
		}
	}

	var count: AsyncStream<Int> {
		let stream = self.countStreamer.makeStream()
		self.countStreamer.send(self.cache.count)
		return stream
	}

	var errors: AsyncStream<any Error> {
		let stream = self.errorStreamer.makeStream()
		while let error = self.cache.first {
			self.errorStreamer.send(error)
			self.cache.removeFirst()
		}
		return stream
	}

	func handle(error: any Error) {
		if !self.errorStreamer.send(error) {
			self.cache.append(error)
		}
	}
}

extension AlertController: @MainActor Equatable {
	static func == (lhs: AlertController, rhs: AlertController) -> Bool {
		lhs === rhs
	}
}
