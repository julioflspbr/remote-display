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
	func `semaphore releases wait when signaled`() async {
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
	func `semaphore fails on double wait`() async throws {
		// given
		let wouldHaveHalted = Mutex<Bool>(false)
		let dependencies = TaskSemaphore.Dependencies {
			wouldHaveHalted << true
		}
		let sut = TaskSemaphore(dependencies: dependencies)

		// when
		let task1 = Task {
			await sut.wait()
		}
		let task2 = Task {
			await sut.wait()
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
	func `semaphore accepts double signal`() async {
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
