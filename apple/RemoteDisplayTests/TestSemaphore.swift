//
//  TestSemaphore.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 05/09/2026.
//

actor TestSemaphore {
	private var handle: AsyncStream<Void>.Continuation?

	func signal() {
		guard let handle else {
			return
		}
		handle.yield()
	}

	func wait() async {
		guard handle == nil else {
			return
		}

		let (stream, continuation) = AsyncStream<Void>.makeStream(bufferingPolicy: .bufferingOldest(0))
		self.handle = continuation
		for await _ in stream {
			self.handle?.finish()
			self.handle = nil
		}
	}
}
