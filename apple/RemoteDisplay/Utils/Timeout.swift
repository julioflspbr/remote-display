//
//  Timeout.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 12/09/2026.
//

struct TimeoutError: Error {
}

func withTimeout<T: Sendable>(_ timeout: Duration, operation: @escaping () async throws -> T) async rethrows -> T {
	let operation = UncheckedBox<T>(operation: operation)
	return try await withThrowingTaskGroup(of: T.self) { group in
		group.addTask {
			try await Task.sleep(for: timeout)
			throw TimeoutError()
		}

		group.addTask {
			try await operation.operation()
		}

		let result = try await group.next()!
		group.cancelAll()
		return result
	}
}

private struct UncheckedBox<T>: @unchecked Sendable {
	let operation: () async throws -> T
}
