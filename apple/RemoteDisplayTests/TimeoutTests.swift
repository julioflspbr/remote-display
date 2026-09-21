//
//  TimeoutTests.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 12/09/2026.
//

import Testing
@testable import RemoteDisplay

@Suite
final class TimeoutTests {
	@Test("no timeout when execution happens successfully and within time limits")
	func succeedOperation() async {
		// given
		let duration: Duration = .milliseconds(5)
		let timeout: Duration = .milliseconds(10)
		let expected = 023945 // random result
		var result: Int?
		var didThrowError = false

		// when
		do {
			result = try await withTimeout(timeout) {
				try await Task.sleep(for: duration)
				return expected
			}
		} catch {
			didThrowError = true
		}

		// then
		#expect(!didThrowError, "The operation is within time limits and should not throw an error")
		#expect(result == expected, "The operation is within time limits and should return the expected result")
	}

	@Test("times out when execution should happen successfully but took too long")
	func failOperationWithTimeout() async {
		// given
		let duration: Duration = .milliseconds(10)
		let timeout: Duration = .milliseconds(5)
		let possible = 023945 // random result
		var result: Int?

		// when
		let task = Task {
			try await withTimeout(timeout) {
				try await Task.sleep(for: duration)
				return possible
			}
		}

		// then
		await #expect(throws: TimeoutError.self, "The operation should throw a timeout error") {
			result = try await task.value
		}

		// then
		#expect(result == nil, "The operation should not return a result")
	}

	@Test("the operation times out before throwing its own error")
	func failThrowingOperationWithTimeout() async {
		// given
		let duration: Duration = .milliseconds(10)
		let timeout: Duration = .milliseconds(5)

		// when
		let task = Task {
			try await withTimeout(timeout) {
				try await Task.sleep(for: duration)
				throw MockError()
			}
		}

		// then
		await #expect(throws: TimeoutError.self, "The operation should throw a timeout error") {
			try await task.value
		}
	}

	@Test("the operation throws its own failure")
	func failThrowingOperationWithItsOwnError() async {
		// given
		let duration: Duration = .milliseconds(5)
		let timeout: Duration = .milliseconds(10)

		// when
		let task = Task {
			try await withTimeout(timeout) {
				try await Task.sleep(for: duration)
				throw MockError()
			}
		}

		// then
		await #expect(throws: MockError.self, "The operation should throw its own error") {
			try await task.value
		}
	}

	@Test("the operations is cancelled and halts before timeout")
	func throwTaskCancellationError() async throws {
		// given
		let wait: Duration = .milliseconds(2)
		let duration: Duration = .milliseconds(5)
		let timeout: Duration = .milliseconds(10)
		let possible = 023945 // random result
		var result: Int?

		// when
		let cancellingTask = Task {
			try await withTimeout(timeout) {
				try await Task.sleep(for: duration)
				return possible
			}
		}

		// then
		await #expect(throws: CancellationError.self, "The operation should throw a cancellation error") {
			try await Task.sleep(for: wait)
			cancellingTask.cancel()
			result = try await cancellingTask.value
		}
		#expect(result == nil, "The operation should not produce a result")
	}

	private struct MockError: Error {
	}
}
