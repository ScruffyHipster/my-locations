//
//  MapViewController.swift
//  MyLocations
//
//  Created by Tom Murray on 22/01/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
	
	@IBOutlet weak var mapView: MKMapView!
	
	var managedObjectContext: NSManagedObjectContext!
	
	@IBAction func showUser() {
		let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
		
		mapView.setRegion(mapView.regionThatFits(region), animated: true)
	}
	
	@IBAction func showLocations() {
		
		}
}

extension MapViewController: MKMapViewDelegate {
	
}
