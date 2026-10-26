//
//  AlertController.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 11/10/2026.
//

import Foundation

@AlertActor
final class AlertController {
	typealias AlertStream = AsyncSequence<Int, Never> & Sendable

	private let countStreamer = MulticastStreamer<Int>()
	private let errorStreamer = MulticastStreamer<any Error>()

	private var stack = AlertStack() {
		didSet {
			self.countStreamer.send(self.stack.count)
		}
	}

	var count: some AlertStream {
		let stream = self.countStreamer.makeStream()
		self.countStreamer.send(self.stack.count)
		return stream.distinct()
	}

	var errors: AsyncStream<any Error> {
		let stream = self.errorStreamer.makeStream()
		for error in self.stack {
			self.errorStreamer.send(error)
		}
		return stream
	}

	func stack(error: any Error) {
		self.stack.stack(error: error)
		self.errorStreamer.send(error)
	}

	func handle(error: any Error) {
		self.stack.handle(error: error)
	}
}

extension AlertController: @AlertActor Equatable {
	static func == (lhs: AlertController, rhs: AlertController) -> Bool {
		lhs === rhs
	}
}
