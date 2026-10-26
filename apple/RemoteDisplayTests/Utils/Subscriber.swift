//
//  Subscriber.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 19/10/2026.
//

import Synchronization
@testable import RemoteDisplay

final class Subscriber<Value: Sendable>: Sendable {
	private let accumulator = Mutex<[Value]>([])

	var accumulated: [Value] {
		self.accumulator>>
	}

	@discardableResult
	func subscribe(to stream: (any AsyncSequence<Value, Never> & Sendable)?) -> Task<Void, Never> {
		Task {
			guard let stream else {
				return
			}
			for await value in stream {
				self.accumulator.withLock { accumulated in
					accumulated.append(value)
				}
			}
		}
	}
}
