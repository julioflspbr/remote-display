//
//  LocalizedStringResource+Debug.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 21/09/2026.
//

#if DEBUG

import Foundation

extension LocalizedStringResource {
	enum debug {
		static let simulationServiceConnectionFailure = LocalizedStringResource("SIMULATION_SERVICE_CONNECTION_FAILURE", table: .debug)
		static let simulationServiceDisconnectionFailure = LocalizedStringResource("SIMULATION_SERVICE_DISCONNECTION_FAILURE", table: .debug)
		static let simulationServiceSearchFailure = LocalizedStringResource("SIMULATION_SERVICE_SEARCH_FAILURE", table: .debug)
	}
}

private extension String {
	static let debug = "Localizable.debug"
}

#endif
