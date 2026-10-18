//
//  Mutex.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 11/10/2026.
//

import Synchronization

postfix operator >>
extension Mutex where Value: Sendable {
	static postfix func >> (mutex: borrowing Mutex<Value>) -> Value {
		mutex.withLock { it in it }
	}
	static func << (mutex: borrowing Mutex<Value>, newValue: Value) {
		mutex.withLock{ it in
			it = newValue
		}
	}
}
