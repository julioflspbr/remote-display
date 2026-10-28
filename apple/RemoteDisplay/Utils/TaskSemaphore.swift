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


	init() {
		self.dependencies = .live
	}

	#if DEBUG
	init(dependencies: Dependencies) {
		self.dependencies = dependencies
	}
	#endif

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
		self.continuation?.resume()
		self.continuation = nil
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
