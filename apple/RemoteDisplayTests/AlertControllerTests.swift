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
		var sut: AlertController! = AlertController()
		let countSubscription = await subscribe(to: sut.count)
		let errorSubscription = await subscribe(to: sut.errors)

		// when
		await sut.stack(error: MockError.error1)
		await sut.stack(error: MockError.error2)
		await sut.stack(error: MockError.error3)

		// then
		sut = nil
		let counter = await countSubscription.value
		let errors = await errorSubscription.value

		try #require(counter.count == 4, "Accumulated count did not accumulate properly")
		#expect(counter[0] == 0, "The initial count was not recorded")
		#expect(counter[1] == 1, "Error count 1 was not recorded")
		#expect(counter[2] == 2, "Error count 2 was not recorded")
		#expect(counter[3] == 3, "Error count 3 was not recorded")

		try #require(errors.count == 3, "Accumulated error count does not match the stacked errors")
		#expect(errors[0] as? MockError == .error1, "The first accumulated error is not correct")
		#expect(errors[1] as? MockError == .error2, "The second accumulated error is not correct")
		#expect(errors[2] as? MockError == .error3, "The third accumulated error is not correct")
	}

	@Test
	func `late subscription get old stacked errors`() async throws {
		// given
		var sut: AlertController! = AlertController()
		let countSubscription = await subscribe(to: sut.count)

		// when
		await sut.stack(error: MockError.error1)
		await sut.stack(error: MockError.error2)
		await sut.stack(error: MockError.error3)

		let errorSubscription = await subscribe(to: sut.errors)

		// then
		try await Task.waitForNextFrame()
		sut = nil
		let counter = await countSubscription.value
		let errors = await errorSubscription.value

		try #require(counter.count == 4, "Accumulated count did not accumulate properly")
		#expect(counter[0] == 0, "The initial count was not recorded")
		#expect(counter[1] == 1, "Error count 1 was not recorded")
		#expect(counter[2] == 2, "Error count 2 was not recorded")
		#expect(counter[3] == 3, "Error count 3 was not recorded")

		try #require(errors.count == 3, "Accumulated error count does not match the stacked errors")
		#expect(errors[0] as? MockError == .error3, "The first accumulated error is not correct")
		#expect(errors[1] as? MockError == .error2, "The second accumulated error is not correct")
		#expect(errors[2] as? MockError == .error1, "The third accumulated error is not correct")
	}

	@Test
	func `handled error get removed from the stack`() async throws {
		// given
		var sut: AlertController! = AlertController()
		await sut.stack(error: MockError.error1)
		await sut.stack(error: MockError.error2)
		await sut.stack(error: MockError.error3)

		// when
		await sut.handle(error: MockError.error2)

		// then
		let countSubscription = await subscribe(to: sut.count)
		let errorSubscription = await subscribe(to: sut.errors)

		try await Task.waitForNextFrame()
		sut = nil
		let counter = await countSubscription.value
		let errors = await errorSubscription.value

		#expect(counter.first == 2, "Error count 3 for handled error was not counted down")

		try #require(errors.count == 2, "Accumulated error count does not match the stacked errors")
		#expect(errors[0] as? MockError == .error3, "The first accumulated error is not correct")
		#expect(errors[1] as? MockError == .error1, "The second accumulated error is not correct")
	}

	@Test
	func `controller only counts and stroes distinkct errors in stack order`() async throws {
		// given
		var sut: AlertController! = AlertController()

		// when
		await sut.stack(error: MockError.error1)
		await sut.stack(error: MockError.error2)

		await sut.stack(error: MockError.error1)
		await sut.stack(error: MockError.error2)

		await sut.stack(error: MockError.error3)
		await sut.stack(error: MockError.error1)
		await sut.stack(error: MockError.error3)

		// then
		let countSubscription = await subscribe(to: sut.count)
		let errorSubscription = await subscribe(to: sut.errors)

		try await Task.waitForNextFrame()
		sut = nil
		let counter = await countSubscription.value
		let errors = await errorSubscription.value

		try #require(counter.count == 1, "Accumulated count did not accumulate properly")
		#expect(counter[0] == 3, "Error count 3 was not recorded")

		try #require(errors.count == 3, "Accumulated error count does not match the stacked errors")
		#expect(errors[0] as? MockError == .error3, "The first accumulated error is not correct")
		#expect(errors[1] as? MockError == .error1, "The second accumulated error is not correct")
		#expect(errors[2] as? MockError == .error2, "The third accumulated error is not correct")
	}
}

private enum MockError: Error, Equatable {
	case error1
	case error2
	case error3
}
