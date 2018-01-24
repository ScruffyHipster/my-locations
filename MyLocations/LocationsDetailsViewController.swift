//
//  LocationsDetailsViewController.swift
//  MyLocations
//
//  Created by Tom Murray on 09/01/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

private let dateFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateStyle = .medium
	formatter.timeStyle = .short
	print()
	return formatter
}()

class LocationDetailsViewController: UITableViewController {
	
	var date = Date()
	var locationToEdit: Location? {
		didSet {
		if let location = locationToEdit {
			descriptionText = location.locationDescription
			categoryName = location.category
			date = location.date
			coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
			placemark = location.placemark
			}
		}
	}
	
	
	//Outlets
	@IBOutlet weak var descriptionTextView: UITextView!
	@IBOutlet weak var categoryLabel: UILabel!
	@IBOutlet weak var latitudeLabel: UILabel!
	@IBOutlet weak var longitudeLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var addPhotoLabel: UILabel!
	
	//Actions
	@IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
		let controller = segue.source as! CategoryPickerViewController
		categoryName = controller.selectedCategoryName
		categoryLabel.text = categoryName
	}
	
	var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
	var placemark: CLPlacemark?
	var categoryName = "No Category"
	var managedObjectcontext: NSManagedObjectContext!
	var descriptionText = ""
	var image: UIImage? {
		didSet {
			if let theImage = image {
				imageView.image = theImage
				imageView.isHidden = false
				imageView.frame = CGRect(x: 10, y: 10, width:260, height: 260)
				addPhotoLabel.isHidden = true
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let location = locationToEdit {
			title = "Edit Location"
		}
		
		descriptionTextView.text = descriptionText
		categoryLabel.text = categoryName
		
		latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
		longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
		
		if let placemark = placemark {
			addressLabel.text = string(from: placemark)
		} else {
			addressLabel.text = "No Address Found"
		}
		
		dateLabel.text = format(date: date)
		
		//hide keyboard
		let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
		
		gestureRecogniser.cancelsTouchesInView = false
		tableView.addGestureRecognizer(gestureRecogniser)
	}
	
	//MARK:- Actions
	@IBAction func done() {
		let hudView = HudView.hud(inView: navigationController!.view, animated: true)
		
		let location: Location
		
		if let temp = locationToEdit {
			hudView.text = "Updated"
			location = temp
		} else {
			hudView.text = "Tapped"
			location = Location(context: managedObjectcontext)
		}
		
		location.locationDescription = descriptionTextView.text
		location.category = categoryName
		location.latitude = coordinate.latitude
		location.longitude = coordinate.longitude
		location.date = date
		location.placemark = placemark
		
		do {
			try managedObjectcontext.save()
			afterDelay(0.8) {
			hudView.hideAnimated(animated: true)
//			hudView.hide()
			self.navigationController?.popViewController(animated: true)
			}
		} catch {
			fatalCoreDataError(error)
		}
	}


	@IBAction func cancel() {
		navigationController?.popViewController(animated: true)
	}
	
//	func show(image: UIImage) {
//		imageView.image = image
//		imageView.isHidden = false
//		imageView.frame = CGRect(x: 10, y: 10, width:260, height: 260)
//		addPhotoLabel.isHidden = true
//	}
	
	//MARK:- Private methods
	
	func string(from: CLPlacemark) -> String {
		var text = ""
		
		if let s = placemark?.subThoroughfare {
			text += s + " "
		}
		if let s = placemark?.thoroughfare {
			text += s + ", "
		}
		if let s = placemark?.locality {
			text += s + "' "
		}
		if let s = placemark?.administrativeArea {
			text += s + " "
		}
		if let s = placemark?.postalCode {
			text += s + ", "
		}
		if let s = placemark?.country {
			text += s
		}
		return text
	}
	
	func format(date: Date) -> String {
		return dateFormatter.string(from: date)
	}
	
	@objc func hideKeyboard(_ gestureRecogniser: UIGestureRecognizer) {
		let point = gestureRecogniser.location(in: tableView)
		let indexPath = tableView.indexPathForRow(at: point)
		
		if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
			return
		}
		descriptionTextView.resignFirstResponder()
	}
	
	
	
	//MARK:- Table View Deletgates
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 0 && indexPath.row == 0 {
			return 88
		} else if indexPath.section == 1 {
			if imageView.isHidden {
				return 44
			} else {
				return 280
			}
		} else if indexPath.section == 2 && indexPath.row == 2 {
			addressLabel.frame.size = CGSize(width: view.bounds.size.width - 120, height: 10000)
			addressLabel.sizeToFit()
			addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 16
				return addressLabel.frame.size.height + 20
		} else {
			return 44
		}
	}
	
	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if indexPath.section == 0 || indexPath.section == 1 {
			return indexPath
		} else {
			return nil
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0 && indexPath.row == 0 {
			descriptionTextView.becomeFirstResponder()
		} else if indexPath.section == 1 && indexPath.row == 0 {
			tableView.deselectRow(at: indexPath, animated: true)
			pickPhoto()
		}
	}
	
	//MARK:- Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "PickCategory" {
			let controller = segue.destination as! CategoryPickerViewController
			controller.selectedCategoryName = categoryName
		}
	}
}

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func takePhotoWithCamera() {
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = .camera
		imagePicker.delegate = self
		imagePicker.allowsEditing = true
		present(imagePicker, animated: true, completion: nil)
	}
	
	//MARK:- Image Picker Delegates
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		dismiss(animated: true, completion: nil)
		image = info[UIImagePickerControllerEditedImage] as? UIImage
		tableView.reloadData()
		dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}
	
	func choosePhotoFromLibrary() {
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = .photoLibrary
		imagePicker.delegate = self
		imagePicker.sourceType = .photoLibrary
		imagePicker.allowsEditing = true
		present(imagePicker, animated: true, completion: nil)
	}
	
	func pickPhoto() {
		if true || UIImagePickerController.isSourceTypeAvailable(.camera) {
			showPhotoMenu()
		} else {
			choosePhotoFromLibrary()
		}
	}
	
	func showPhotoMenu() {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alert.addAction(actCancel)
		let actPhoto = UIAlertAction(title: "Take Photo", style: .default, handler: {_ in self.takePhotoWithCamera()})
		alert.addAction(actPhoto)
		let actLibrary = UIAlertAction(title: "Choose From Library", style: .default, handler: {_ in self.choosePhotoFromLibrary()})
		alert.addAction(actLibrary)
		
		present(alert, animated: true, completion: nil)
	}
}
	


