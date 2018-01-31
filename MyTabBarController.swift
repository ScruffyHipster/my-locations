//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Tom Murray on 29/01/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import Foundation
import UIKit

class MyTabBarController: UITabBarController {
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return . lightContent
	}
	
	override var childViewControllerForStatusBarStyle: UIViewController? {
		return nil
	}
}
