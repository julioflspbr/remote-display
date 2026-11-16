//
//  Equatable+IsEqual.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 28/10/2026.
//

extension Equatable {
	func isEqual(to rhs: Any) -> Bool {
		guard let rhsEq = rhs as? Self else {
			return false
		}
		return self == rhsEq
	}
}

extension Optional where Wrapped == any Equatable {
	func isEqual(to rhs: Any) -> Bool {
		self?.isEqual(to: rhs) ?? false
	}
}
