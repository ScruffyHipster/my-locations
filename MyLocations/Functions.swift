//
//  Functions.swift
//  MyLocations
//
//  Created by Tom Murray on 12/01/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import Foundation

var applicationDocumentsDirectory : URL = {
	let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	return paths[0]
}()

let CoreDataSaveFailedNotification = Notification.Name(rawValue: "CoreDataSaveFailedNotification")

func fatalCoreDataError(_ error: Error) {
	print("*** Fatal error: \(error)")
	NotificationCenter.default.post(name: CoreDataSaveFailedNotification, object: nil)
}

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
	DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}

