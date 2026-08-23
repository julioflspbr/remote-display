//
//  String+Utils.swift
//  RemoteDisplay
//
//  Created by Júlio Flores on 18/08/2026.
//

extension String {
	subscript (safe index: Int) -> Character {
		guard let index = self.index(self.startIndex, offsetBy: index, limitedBy: self.index(before: self.endIndex)) else {
			return " "
		}
		return self[index]
	}
}
