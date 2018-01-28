//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by Tom Murray on 28/01/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//
import UIKit

extension UIImage {
	func resized(withBounds bounds: CGSize) -> UIImage {
		let horizontalRatio = bounds.width / size.width
		let verticalRatio = bounds.height / size.height
		let ratio = min(horizontalRatio, verticalRatio)
		let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
		
		UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
		draw(in: CGRect(origin: CGPoint.zero, size: newSize))
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage!
	}
}
