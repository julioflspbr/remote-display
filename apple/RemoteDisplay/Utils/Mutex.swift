//
//  Mutex.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 11/10/2026.
//

import Synchronization

prefix operator *
postfix operator >>
extension Mutex {
	static prefix func * (mutex: borrowing Mutex<Value>) -> Value {
		mutex.withLock{ it in it }
	}

	static postfix func >> (mutex: borrowing Mutex<Value>) -> Value {
		mutex.withLock{ it in it }
	}
}
