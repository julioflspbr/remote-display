//
//  TaskSemaphore.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 15/10/2026.
//

import Synchronization

actor TaskSemaphore {
	// TODO: make Mutex operator accept assignment
	private var isSignaled = false
	private var continuation: CheckedContinuation<Void, Never>?

	func wait(doubleWaitErrorHandler: (() -> Void)? = nil) async {
		guard !isSignaled else {
			return
		}
		guard continuation == nil else {
			if let doubleWaitErrorHandler {
				doubleWaitErrorHandler()
				return
			} else {
				fatalError("The semaphore is busy")
			}
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
