//
//  Cell.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 22/08/2026.
//

extension Display.Line {
	enum Cell: Equatable {
		case char(Character)
		case cursor
		case blank
	}
}
