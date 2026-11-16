//
//  AlertQueue.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 26/10/2026.
//

@AlertActor
struct AlertStack {
	private var storage = [any Error]()

	var count: Int {
		self.storage.count
	}

	var top: (any Error)? {
		self.storage.last
	}

	mutating func stack(error: any Error) {
		self.storage.stack(error: error)
	}

	mutating func handle(error: any Error) {
		self.storage.remove(error: error)
	}
}

extension AlertStack: @AlertActor Sequence {
	func makeIterator() -> Array<any Error>.Iterator {
		self.storage.reversed().makeIterator()
	}
}

private extension Array where Element: Error {
	private func predicate(error: any Error) -> (any Error) -> Bool {
		{ stored in
			let storedEq = stored as any Equatable
			return storedEq.isEqual(to: error)
		}
	}

	mutating func remove(error: Element) {
		self.removeAll(where: predicate(error: error))
	}

	mutating func stack(error: Element) {
		self.removeAll(where: predicate(error: error))
		self.append(error)
	}
}
