//
//  ServiceActor.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 15/09/2026.
//

@globalActor
actor ServiceActor {
	static let shared = ServiceActor()

	static func run<R: Sendable>(operation: @ServiceActor () async throws -> R) async rethrows -> R {
		try await operation()
	}
}
