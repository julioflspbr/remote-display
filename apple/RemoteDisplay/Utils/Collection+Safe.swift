//
//  Collection+Safe.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 14/09/2026.
//

extension Collection {
	subscript(safe index: Index) -> Element? {
		indices.contains(index) ? self[index] : nil
	}
}
