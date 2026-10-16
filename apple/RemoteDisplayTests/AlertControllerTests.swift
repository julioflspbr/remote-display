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
		let collector = Mutex<[MockError?]>([])
		let collectTask = Task {
			for await error in await sut.errors {
				collector.withLock { collector in
					collector.append(error as? MockError)
				}
			}
		}
		try await Task.waitForNextFrame()

		// when
		await sut.handle(error: MockError.error1)
		await sut.handle(error: MockError.error2)
		await sut.handle(error: MockError.error3)

		// then
		try await Task.waitForNextFrame()
		#expect((collector>>)[0] == MockError.error1, "The collector did not catch the first error")
		#expect((collector>>)[1] == MockError.error2, "The collector did not catch the second error")
		#expect((collector>>)[2] == MockError.error3, "The collector did not catch the third error")

		// teardown
		collectTask.cancel()
	}

	@Test
	func `errors accumulate before subscription and are sent after`() async throws {
		// given
		let sut = AlertController()
		let collector = Mutex<[MockError?]>([])
		let collectTask: Task<Void, Never>
		try await Task.waitForNextFrame()

		// when
		await sut.handle(error: MockError.error1)
		await sut.handle(error: MockError.error2)
		await sut.handle(error: MockError.error3)

		collectTask = Task {
			for await error in await sut.errors {
				collector.withLock { collector in
					collector.append(error as? MockError)
				}
			}
		}
		try await Task.waitForNextFrame()

		// then
		#expect((collector>>)[0] == MockError.error1, "The collector did not catch the first error")
		#expect((collector>>)[1] == MockError.error2, "The collector did not catch the second error")
		#expect((collector>>)[2] == MockError.error3, "The collector did not catch the third error")

		// teardown
		collectTask.cancel()
	}
}

private enum MockError: Error, Equatable {
	case error1
	case error2
	case error3
}
