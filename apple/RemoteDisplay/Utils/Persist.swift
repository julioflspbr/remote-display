//
//  Persist.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 12/09/2026.
//

import Foundation

@propertyWrapper struct Persist<T: Codable> {
	private let storage = UserDefaults.standard
	private let encoder = JSONEncoder()
	private let decoder = JSONDecoder()

	let key: String

	var wrappedValue: T {
		didSet {
			if let data = try? self.encoder.encode(wrappedValue) {
				self.storage.set(data, forKey: key)
			}
		}
	}

	init(wrappedValue: T, key: String) {
		self.key = key

		if let data = self.storage.data(forKey: key), let value = try? self.decoder.decode(T.self, from: data) {
			self.wrappedValue = value
		} else {
			self.wrappedValue = wrappedValue

			if let data = try? self.encoder.encode(wrappedValue) {
				self.storage.set(data, forKey: key)
			}
		}
	}
}
