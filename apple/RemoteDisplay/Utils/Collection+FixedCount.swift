//
//  Collection+FixedCount.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 22/08/2026.
//

typealias Fixed<T: Collection> = FixedCount<T>

@propertyWrapper struct FixedCount<T> where T: Collection {
	let fixedCount: Int
	private var _wrappedValue: T
	var wrappedValue: T {
		get {
			_wrappedValue
		}
		set {
			if newValue.count != fixedCount {
				fatalError("This property needs to contain exactly \(fixedCount) elements")
			}
			_wrappedValue = newValue
		}
	}

	init(wrappedValue: T) {
		self._wrappedValue = wrappedValue
		self.fixedCount = wrappedValue.count
	}
}
