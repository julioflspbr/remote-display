//
//  TaskSemaphore.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 15/10/2026.
//

import Synchronization

actor TaskSemaphore {
	private let dependencies: Dependencies
	private var isSignaled = false
	private var continuation: CheckedContinuation<Void, Never>?

	init(dependencies: Dependencies = .live) {
		self.dependencies = dependencies
	}


	func wait() async {
		guard !isSignaled else {
			return
		}
		guard continuation == nil else {
			self.dependencies.doubleWaitErrorHandler()
			return
		}
		self.isSignaled = false
		await withTaskCancellationHandler {
			await withCheckedContinuation { continuation in
				self.setContinuation(continuation)
			}
		} onCancel: {
			Task { [weak self] in
				await self?.setContinuation(nil)
			}
		}
	}

	func signal() {
		continuation?.resume()
		continuation = nil
		self.isSignaled = true
	}

	private func setContinuation(_ continuation: CheckedContinuation<Void, Never>?) {
		self.continuation = continuation
	}
}

extension TaskSemaphore {
	struct Dependencies: Sendable {
		let doubleWaitErrorHandler: @Sendable () -> Void

		static let live = Dependencies {
			fatalError("The semaphore is busy")
		}
	}
}
