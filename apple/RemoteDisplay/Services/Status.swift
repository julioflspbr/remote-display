//
//  Status.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 15/09/2026.
//

extension Services {
	enum Status: Equatable {
		case unavailable
		case searching
		case available
		case connecting
		case connected
		case disconnecting
		case disconnected
		case failure(Error)

		static func == (lhs: Status, rhs: Status) -> Bool {
			switch (lhs, rhs) {
				case (.unavailable, .unavailable):
					return true
				case (.searching, .searching):
					return true
				case (.available, .available):
					return true
				case (.connecting, .connecting):
					return true
				case (.connected, .connected):
					return true
				case (.disconnecting, .disconnecting):
					return true
				case (.disconnected, .disconnected):
					return true
				case let (.failure(lhsError), .failure(rhsError)):
					return type(of: lhsError) == type(of: rhsError)
				default:
					return false
			}
		}
	}
}
