//
//  Display.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 22/08/2026.
//

struct Display {
	enum Specs {
		static let lineCount: Int = 2
		static var charCount: Int {
			lineCount * Line.Specs.charCount
		}
	}

	@Fixed var lines = [Line](repeating: .init(), count: Specs.lineCount)
}
