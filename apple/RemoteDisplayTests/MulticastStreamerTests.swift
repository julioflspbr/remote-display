//
//  MulticastStreamerTests.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 13/10/2026.
//

import Testing
import Synchronization
@testable import RemoteDisplay

struct MulticastStreamerTests {
	@Test
	func streamerCancelsSubscriptionUponRelease() async throws {
		// given
		var streamer: MulticastStreamer<Character>? = MulticastStreamer()
		let client = Subscriber<Character>()
		let task = client.subscribe(to: streamer?.makeStream())

		// when
		streamer = nil
		_ = await task.result

		// then
		// success, the test did not lock at await task.result
	}
	@Test
	func streamerPublishesValuesToMultipleSubscribers() async throws {
		// given
		var streamer: MulticastStreamer<Character>? = MulticastStreamer()
		let client1 = Subscriber<Character>()
		let client2 = Subscriber<Character>()
		let task1 = client1.subscribe(to: streamer?.makeStream())
		let task2 = client2.subscribe(to: streamer?.makeStream())

		// when
		streamer?.send("a")
		streamer?.send("b")
		streamer?.send("c")

		// then
		streamer = nil
		_ = await task1.result
		_ = await task2.result

		#expect(client1.accumulated>> == ["a", "b", "c"], "The accumalation did not collect all sent values")
		#expect(client2.accumulated>> == ["a", "b", "c"], "The accumalation did not collect all sent values")
	}

}

private final class Subscriber<Value: Sendable>: Sendable {
	let accumulated = Mutex<[Value]>([])

	func subscribe(to stream: sending AsyncStream<Value>?) -> Task<Void, Never> {
		Task {
			guard let stream else {
				return
			}
			for await value in stream {
				self.accumulated.withLock { accumulated in
					accumulated.append(value)
				}
			}
		}
	}
}
