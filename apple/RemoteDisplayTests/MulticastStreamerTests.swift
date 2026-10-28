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
	func `streamer cancels subscription upon release`() async throws {
		// given
		var sut: Multicast.Streamer<Void>? = Multicast.Streamer()
		let task = subscribe(to: sut?.makeStream())
		try await Task.waitForNextFrame()

		// when
		sut?.send(value: ())
		sut = nil

		// then
		_ = await task.result
		// success, the test did not lock at await task.result
	}

	@Test
	func `streamer publishes values to multiple subscribers`() async throws {
		// given
		let sut = Multicast.Streamer<Character>()
		let client1 = subscribe(to: sut.makeStream())
		let client2 = subscribe(to: sut.makeStream())
		try await Task.waitForNextFrame()

		// when
		sut.send(value: "a")
		sut.send(value: "b")
		sut.send(value: "c")

		// then
		sut.finish()
		await #expect(client1.value == ["a", "b", "c"], "The accumalation did not collect all sent values")
		await #expect(client2.value == ["a", "b", "c"], "The accumalation did not collect all sent values")
	}

	@Test
	func `errors are propagated to all subscriptions`() async throws {
		// given
		let sut = Multicast.ThrowingStreamer<Void, TestError>()
		let client1 = subscribe(to: sut.makeStream())
		let client2 = subscribe(to: sut.makeStream())
		try await Task.waitForNextFrame()

		// when
		sut.throw(error: TestError.mock)

		// then
		await #expect(throws: TestError.mock) {
			try await client1.value
		}
		await #expect(throws: TestError.mock) {
			try await client2.value
		}
	}

	@Test
	func `isStreaming reflects subscription count`() async throws {
		// given
		let sut = Multicast.Streamer<Void>()

		// when
		subscribe(to: sut.makeStream())
		try await Task.waitForNextFrame()
		// then
		#expect(sut.isStreaming, "There are subscriptions, but isStreaming says no")

		// when
		sut.finish()
		// then
		#expect(!sut.isStreaming, "There are no subscriptions, but isStreaming says yes")
	}
}

private enum TestError: Swift.Error {
	case mock
}
