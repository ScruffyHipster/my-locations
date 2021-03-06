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
	var dynamicHeight: CGFloat?
	var observer: Any!
	var image: UIImage? {
		didSet {
			if let theImage = image {
				imageView.image = theImage
				imageView.isHidden = false
				addPhotoLabel.isHidden = true
				imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
				let aspectRatio = theImage.size.width / theImage.size.height
				dynamicHeight = (280 / aspectRatio)

				}
			}
		}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let location = locationToEdit {
			title = "Edit Location"
			if location.hasPhoto {
				if let theImage = location.photoImage {
					image = theImage
				}
			}
		}
		
		listenForBackgroundNotifications()
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
	
	deinit {
		print("*** deinit \(self)")
		NotificationCenter.default.removeObserver(observer)
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
			location.photoID = nil
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
		
		//Save Image
		if let image = image {
			//1
			if  !location.hasPhoto {
				location.photoID = Location.nextPhotoID() as NSNumber
			}
			//2
			if let data = UIImageJPEGRepresentation(image, 0.5) {
				do {
					try data.write(to: location.photoURL, options: .atomic)
				} catch {
					print("Error writing file: \(error)")
				}
			}
			print("the URL is \(location.photoURL)")
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
		var line = ""
		
		line.add(text: placemark?.subThoroughfare)
		line.add(text: placemark?.thoroughfare, seperatedBy: " ")
		line.add(text: placemark?.locality, seperatedBy: " , ")
		line.add(text: placemark?.administrativeArea, seperatedBy: ", ")
		line.add(text: placemark?.postalCode, seperatedBy: " ")
		line.add(text: placemark?.country, seperatedBy: ", ")
		return line
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
	
	func listenForBackgroundNotifications() {
		observer = NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidEnterBackground, object: nil, queue: OperationQueue.main) { [weak self] _ in
			if let weakSelf = self {
				if weakSelf.presentedViewController != nil {
				weakSelf.dismiss(animated: false, completion: nil)
			}
			weakSelf.descriptionTextView.resignFirstResponder()
			}
			print(self)
		}
	}
	
	
	
	//MARK:- Table View Deletgates
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		switch (indexPath.section, indexPath.row) {
		case (0, 0):
			return 88
		case (1, _):
			return imageView.isHidden ? 44 : dynamicHeight!
		case (2, 2):
			addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 1000)
			addressLabel.sizeToFit()
			addressLabel.frame.origin.x = view.bounds.size.width - 15
			return addressLabel.frame.size.height + 20
		default:
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
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let selection = UIView(frame: CGRect.zero)
		selection.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
		cell.selectedBackgroundView = selection
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
		let imagePicker = MyImagePickerController()
		imagePicker.sourceType = .camera
		imagePicker.delegate = self
		imagePicker.allowsEditing = true
		imagePicker.view.tintColor = view.tintColor
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
		let imagePicker = MyImagePickerController()
		imagePicker.view.tintColor = view.tintColor
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
	


