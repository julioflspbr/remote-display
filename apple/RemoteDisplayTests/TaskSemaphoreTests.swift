//
//  TaskSemaphoreTests.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 15/10/2026.
//

import Testing
import Synchronization
@testable import RemoteDisplay

final class TestSemaphoreTests {
	@Test(.timeLimit(.minutes(1)))
	func semaphoreReleasesWaitWhenSignaled() async {
		// given
		let sut = TaskSemaphore()

		// when
		Task {
			await sut.signal()
		}
		await sut.wait()

		// then
		// success: the runtime is not stuck
	}

	@Test
	func semaphoreFailsOnDoubleWait() async throws {
		// given
		let sut = TaskSemaphore()
		let wouldHaveHalted = Mutex<Bool>(false)

		// when
		let doubleWaitHandler: (@Sendable () -> Void) = {
			wouldHaveHalted << true
		}
		let task1 = Task {
			await sut.wait(doubleWaitErrorHandler: doubleWaitHandler)
		}
		let task2 = Task {
			await sut.wait(doubleWaitErrorHandler: doubleWaitHandler)
		}
		// let tasks spool up
		try await Task.sleep(for: .milliseconds(1))

		// then
		#expect(wouldHaveHalted>>, "The semaphore did not halt when wait() was called twice")

		// teardown
		task1.cancel()
		task2.cancel()
	}

	@Test(.timeLimit(.minutes(1)))
	func semaphoreAcceptsDoubleSignal() async {
		// given
		let sut = TaskSemaphore()

		// when
		await sut.signal()
		await sut.signal()
		await sut.signal()

		await sut.wait()

		// then
		// success: the runtime is not stuck
	}
}
