//
//  String+AddText.swift
//  MyLocations
//
//  Created by Tom Murray on 29/01/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import Foundation


extension String {
	mutating func add(text: String?, seperatedBy seperator: String = "") {
		if let text = text {
			if !isEmpty {
				self += seperator
			}
			self += text
		}
	}
}
