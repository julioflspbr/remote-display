//
//  MulticastStreamerTests.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 13/10/2026.
//

import Testing
@testable import RemoteDisplay

struct MulticastStreamerTests {
	@Test
	func `streamer cancels subscription upon relesae`() async throws {
		// given
		var streamer: MulticastStreamer<Character>? = MulticastStreamer()
		let client = Subscriber<Character>()
		let task = client.subscribe(to: streamer?.makeStream())

		// when
		streamer = nil

		// then
		_ = await task.result
		// success, the test did not lock at await task.result
	}

	@Test
	func `streamer publishes values to multiple subscribers`() async throws {
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

		#expect(client1.accumulated == ["a", "b", "c"], "The accumalation did not collect all sent values")
		#expect(client2.accumulated == ["a", "b", "c"], "The accumalation did not collect all sent values")
	}

}
