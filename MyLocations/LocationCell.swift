//
//  LocationCell.swift
//  MyLocations
//
//  Created by Tom Murray on 17/01/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
	
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	
	@IBOutlet weak var photoImageView: UIImageView!
	
	func configure(for location: Location) {
		if location.locationDescription.isEmpty {
			descriptionLabel.text = "(No Description)"
			photoImageView.image = thumbnail(for: location)
		} else {
			descriptionLabel.text = location.locationDescription
		}
	
	if let placemark = location.placemark {
		var text = ""
		if let s = placemark.subThoroughfare {
			text += s + " "
		}
		if let s = placemark.thoroughfare {
			text += s + ", "
		}
		if let s = placemark.locality {
		text += s
	}
	addressLabel.text = text
	} else {
		addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
	}
}
		
		override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func thumbnail(for location: Location) -> UIImage {
		if location.hasPhoto, let image = location.photoImage {
			return image
		}
		return UIImage()
	}

}
