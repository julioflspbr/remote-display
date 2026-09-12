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
	func failOperationWithTimeout() async throws {
		// given
		let duration: Duration = .milliseconds(10)
		let timeout: Duration = .milliseconds(5)
		let possible = 023945 // random result
		var errorThrown: Error?
		var result: Int?

		// when
		do {
			result = try await withTimeout(timeout) {
				try await Task.sleep(for: duration)
				return possible
			}
		} catch {
			errorThrown = error
		}

		// then
		let error = try #require(errorThrown, "The operation should throw an error")
		#expect(error is TimeoutError, "The operation should throw a timeout error")
		#expect(result == nil, "The operation should not return a result")
	}

	@Test("the operation throws its own failure")
	func failThrowingOperationWithItsOwnError() async throws {
		// given
		let duration: Duration = .milliseconds(5)
		let timeout: Duration = .milliseconds(10)
		var errorThrown: Error?

		// when
		do {
			try await withTimeout(timeout) {
				try await Task.sleep(for: duration)
				throw MockError()
			}
		} catch {
			errorThrown = error
		}

		// then
		let error = try #require(errorThrown, "The operation should throw an error")
		#expect(error is MockError, "The operation should throw its own error")
	}

	@Test("the operation times out before throwing its own error")
	func failThrowingOperationWithTimeout() async throws {
		// given
		let duration: Duration = .milliseconds(10)
		let timeout: Duration = .milliseconds(5)
		var errorThrown: Error?

		// when
		do {
			try await withTimeout(timeout) {
				try await Task.sleep(for: duration)
				throw MockError()
			}
		} catch {
			errorThrown = error
		}

		// then
		let error = try #require(errorThrown, "The operation should throw an error")
		#expect(error is TimeoutError, "The operation should throw a timeout error")
	}

	private struct MockError: Error {
	}
}
