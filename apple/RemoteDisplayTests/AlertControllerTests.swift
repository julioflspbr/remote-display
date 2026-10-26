//
//  AlertControllerTests.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 17/10/2026.
//

import Testing
@testable import RemoteDisplay

final class AlertControllerTests {
	@Test
	func `errors sent to the controller are stored`() async throws {
		// given
		let sut = AlertController()
		let countSubscriber = Subscriber<Int>()
		let errorSubscriber = Subscriber<any Error>()
		await countSubscriber.subscribe(to: sut.count)
		await errorSubscriber.subscribe(to: sut.errors)

		// when
		await sut.stack(error: MockError.error1)
		await sut.stack(error: MockError.error2)
		await sut.stack(error: MockError.error3)

		// then
		try await Task.waitForNextFrame()
		try #require(countSubscriber.accumulated.count == 4, "Accumulated count did not accumulate properly")
		#expect(countSubscriber.accumulated[0] == 0, "The initial count was not recorded")
		#expect(countSubscriber.accumulated[1] == 1, "Error count 1 was not recorded")
		#expect(countSubscriber.accumulated[2] == 2, "Error count 2 was not recorded")
		#expect(countSubscriber.accumulated[3] == 3, "Error count 3 was not recorded")

		try #require(errorSubscriber.accumulated.count == 3, "Accumulated error count does not match the stacked errors")
		#expect(errorSubscriber.accumulated[0] as? MockError == .error1, "The first accumulated error is not correct")
		#expect(errorSubscriber.accumulated[1] as? MockError == .error2, "The second accumulated error is not correct")
		#expect(errorSubscriber.accumulated[2] as? MockError == .error3, "The third accumulated error is not correct")
	}

	@Test
	func `late subscription get old stacked errors`() async throws {
		// given
		let sut = AlertController()
		let countSubscriber = Subscriber<Int>()
		let errorSubscriber = Subscriber<any Error>()
		await countSubscriber.subscribe(to: sut.count)

		// when
		await sut.stack(error: MockError.error1)
		await sut.stack(error: MockError.error2)
		await sut.stack(error: MockError.error3)

		await errorSubscriber.subscribe(to: sut.errors)

		// then
		try await Task.waitForNextFrame()
		try #require(countSubscriber.accumulated.count == 4, "Accumulated count did not accumulate properly")
		#expect(countSubscriber.accumulated[0] == 0, "The initial count was not recorded")
		#expect(countSubscriber.accumulated[1] == 1, "Error count 1 was not recorded")
		#expect(countSubscriber.accumulated[2] == 2, "Error count 2 was not recorded")
		#expect(countSubscriber.accumulated[3] == 3, "Error count 3 was not recorded")

		try #require(errorSubscriber.accumulated.count == 3, "Accumulated error count does not match the stacked errors")
		#expect(errorSubscriber.accumulated[0] as? MockError == .error3, "The first accumulated error is not correct")
		#expect(errorSubscriber.accumulated[1] as? MockError == .error2, "The second accumulated error is not correct")
		#expect(errorSubscriber.accumulated[2] as? MockError == .error1, "The third accumulated error is not correct")
	}

	@Test
	func `handled error get removed from the stack`() async throws {
		// given
		let sut = AlertController()
		let countSubscriber = Subscriber<Int>()
		let errorSubscriber = Subscriber<any Error>()

		await sut.stack(error: MockError.error1)
		await sut.stack(error: MockError.error2)
		await sut.stack(error: MockError.error3)
		try await Task.waitForNextFrame()

		// when
		await sut.handle(error: MockError.error2)

		// then
		await countSubscriber.subscribe(to: sut.count)
		await errorSubscriber.subscribe(to: sut.errors)
		try await Task.waitForNextFrame()

		#expect(countSubscriber.accumulated.first == 2, "Error count 3 for handled error was not counted down")

		try #require(errorSubscriber.accumulated.count == 2, "Accumulated error count does not match the stacked errors")
		#expect(errorSubscriber.accumulated[0] as? MockError == .error3, "The first accumulated error is not correct")
		#expect(errorSubscriber.accumulated[1] as? MockError == .error1, "The second accumulated error is not correct")
	}

	@Test
	func `controller only counts and stroes distinkct errors in stack order`() async throws {
		// given
		let sut = AlertController()
		let countSubscriber = Subscriber<Int>()
		let errorSubscriber = Subscriber<any Error>()

		// when
		await sut.stack(error: MockError.error1)
		await sut.stack(error: MockError.error2)

		await sut.stack(error: MockError.error1)
		await sut.stack(error: MockError.error2)

		await sut.stack(error: MockError.error3)
		await sut.stack(error: MockError.error1)
		await sut.stack(error: MockError.error3)

		// then
		await countSubscriber.subscribe(to: sut.count)
		await errorSubscriber.subscribe(to: sut.errors)
		try await Task.waitForNextFrame()

		try #require(countSubscriber.accumulated.count == 1, "Accumulated count did not accumulate properly")
		#expect(countSubscriber.accumulated[0] == 3, "Error count 3 was not recorded")

		try #require(errorSubscriber.accumulated.count == 3, "Accumulated error count does not match the stacked errors")
		#expect(errorSubscriber.accumulated[0] as? MockError == .error3, "The first accumulated error is not correct")
		#expect(errorSubscriber.accumulated[1] as? MockError == .error1, "The second accumulated error is not correct")
		#expect(errorSubscriber.accumulated[2] as? MockError == .error2, "The third accumulated error is not correct")
	}
}

private enum MockError: Error, Equatable {
	case error1
	case error2
	case error3
}
