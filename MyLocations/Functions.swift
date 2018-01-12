//
//  Functions.swift
//  MyLocations
//
//  Created by Tom Murray on 12/01/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
	DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}
