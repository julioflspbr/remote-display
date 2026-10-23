//
//  AlertControllerTests.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 17/10/2026.
//

import Testing
import Synchronization
@testable import RemoteDisplay

final class AlertControllerTests {
	@Test
	func `errors marked as handled are streamed forward`() async throws {
		// given
		let sut = AlertController()
		let subscriber = Subscriber<any Error>()
		await subscriber.subscribe(to: sut.errors)

		// when
		await sut.handle(error: MockError.error1)
		await sut.handle(error: MockError.error2)
		await sut.handle(error: MockError.error3)

		// then
		try await Task.waitForNextFrame()
		try #require(subscriber.accumulated.count == 3, "The accumulated errors count is different from the number of errors thrown")

		#expect(subscriber.accumulated[0] as? MockError == .error1, "The collector did not catch the first error")
		#expect(subscriber.accumulated[1] as? MockError == .error2, "The collector did not catch the second error")
		#expect(subscriber.accumulated[2] as? MockError == .error3, "The collector did not catch the third error")
	}

	@Test
	func `errors accumulate before subscription and are sent after`() async throws {
		// given
		let sut = AlertController()
		let subscriber = Subscriber<any Error>()

		// when
		await sut.handle(error: MockError.error1)
		await sut.handle(error: MockError.error2)
		await sut.handle(error: MockError.error3)

		await subscriber.subscribe(to: sut.errors)

		// then
		try await Task.waitForNextFrame()
		try #require(subscriber.accumulated.count == 3, "The accumulated errors count is different from the number of errors thrown")

		#expect(subscriber.accumulated[0] as? MockError == .error1, "The collector did not catch the first error")
		#expect(subscriber.accumulated[1] as? MockError == .error2, "The collector did not catch the second error")
		#expect(subscriber.accumulated[2] as? MockError == .error3, "The collector did not catch the third error")
	}

	@Test
	func `error cache count shows zero because the errors are consumed immediately`() async throws {
		// given
		let sut = AlertController()
		let subscriber = Subscriber<Int>()
		let dummy = Subscriber<any Error>()
		await subscriber.subscribe(to: sut.count)
		await dummy.subscribe(to: sut.errors)

		// when
		await sut.handle(error: MockError.error1)
		await sut.handle(error: MockError.error2)
		await sut.handle(error: MockError.error3)

		// then
		try await Task.waitForNextFrame()
		try #require(subscriber.accumulated.count == 1, "The counter did not produce the initial value")

		#expect(subscriber.accumulated[0] == 0, "The counter should show the initial value 0")
	}

	@Test
	func `error cache count should show count of accumulated errors count`() async throws {
		// given
		let sut = AlertController()
		let subscriber = Subscriber<Int>()
		await subscriber.subscribe(to: sut.count)
		try await Task.waitForNextFrame()

		// when
		await sut.handle(error: MockError.error1)
		await sut.handle(error: MockError.error2)
		await sut.handle(error: MockError.error3)

		// then
		try await Task.waitForNextFrame()
		try #require(subscriber.accumulated.count == 4, "The counter did not accumulate all errors correctly")

		#expect(subscriber.accumulated[0] == 0, "The counter should show the initial value 0")
		#expect(subscriber.accumulated[1] == 1, "The counter should show 1 error accumulated")
		#expect(subscriber.accumulated[2] == 2, "The counter should show 2 errors accumulated")
		#expect(subscriber.accumulated[3] == 3, "The counter should show 3 errors accumulated")
	}
}

private enum MockError: Error, Equatable {
	case error1
	case error2
	case error3
}
