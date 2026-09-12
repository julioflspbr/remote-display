//
//  Line.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 22/08/2026.
//

extension Display {
	struct Line {
		enum Specs {
			static let charCount: Int = 16
		}

		@Fixed var cells = [Cell](repeating: .blank, count: Specs.charCount)
	}
}
