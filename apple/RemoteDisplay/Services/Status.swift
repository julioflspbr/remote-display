//
//  Status.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 15/09/2026.
//

extension Services {
	enum Status: Hashable {
		case unavailable
		case searching
		case available
		case connecting
		case connected
		case disconnecting
		case disconnected
		case failure(any Error)

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

		func hash(into hasher: inout Hasher) {
			switch self {
				case .unavailable:
					hasher.combine(0)
				case .searching:
					hasher.combine(1)
				case .available:
					hasher.combine(2)
				case .connecting:
					hasher.combine(3)
				case .connected:
					hasher.combine(4)
				case .disconnecting:
					hasher.combine(5)
				case .disconnected:
					hasher.combine(6)
				case let .failure(error):
					hasher.combine(7)
					hasher.combine(ObjectIdentifier(type(of: error)))
			}
		}
	}
}
