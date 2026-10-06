//
//  Task+NextFrame.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 17/10/2026.
//

extension Task where Success == Never, Failure == Never {
	static func waitForNextFrame() async throws {
		try await Self.sleep(for: .milliseconds(1))
	}
}
