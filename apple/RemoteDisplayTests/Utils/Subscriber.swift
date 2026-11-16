//
//  Subscriber.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 19/10/2026.
//

@testable import RemoteDisplay

@discardableResult
func subscribe<Value, Failure: Error>(to stream: (any AsyncSequence<Value, Failure> & Sendable)?) -> Task<[Value], any Error> {
	Task {
		guard let stream else {
			return []
		}
		var accumulator = [Value]()
		for try await value in stream {
			accumulator.append(value)
		}
		return accumulator
	}
}

@discardableResult
func subscribe<Value>(to stream: (any AsyncSequence<Value, Never> & Sendable)?) -> Task<[Value], Never> {
	Task {
		guard let stream else {
			return []
		}
		var accumulator = [Value]()
		for await value in stream {
			accumulator.append(value)
		}
		return accumulator
	}
}
