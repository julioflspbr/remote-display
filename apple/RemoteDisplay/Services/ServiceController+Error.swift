//
//  ServiceController+Error.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 14/09/2026.
//

import Foundation

extension Services.ServiceController {
	protocol Error: LocalizedError, Equatable {
	}

	final class NoBuiltInServiceError: Services.ServiceController.Error {
		var errorDescription: String? {
			String(localized: .errorDescriptionNoBuiltIn)
		}
	}

	final class ChangeServiceWhileConnectedError: Services.ServiceController.Error {
		var errorDescription: String? {
			String(localized: .errorDescriptionChangeWhileConnected)
		}

		var recoverySuggestion: String? {
			String(localized: .errorRecoveryChangeWhileConnected)
		}
	}
}

extension Services.ServiceController.Error  {
	static func == (lhs: Self, rhs: Self) -> Bool {
		type(of: lhs) == type(of: rhs)
	}
}
