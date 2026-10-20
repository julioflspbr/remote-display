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
		try await Task.waitForNextFrame()

		// then
		#expect(subscriber.accumulated[0] as? MockError == .error1, "The collector did not catch the first error")
		#expect(subscriber.accumulated[1] as? MockError == .error2, "The collector did not catch the second error")
		#expect(subscriber.accumulated[2] as? MockError == .error3, "The collector did not catch the third error")
	}
}

private enum MockError: Error, Equatable {
	case error1
	case error2
	case error3
}
