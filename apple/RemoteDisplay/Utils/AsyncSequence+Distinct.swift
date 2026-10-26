//
//  AsyncSequence+Distinct.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 28/10/2026.
//

import Synchronization

extension AsyncSequence where Self: Sendable, Element: Equatable & Sendable {
	func distinct() -> some AsyncSequence<Element, Failure> & Sendable {
		let last = Mutex<Element?>(nil)
		return self.filter { value in
			last.withLock { last in
				let isEqual = (last.isEqual(to: value))
				last = value
				return !isEqual
			}
		}
	}
}

