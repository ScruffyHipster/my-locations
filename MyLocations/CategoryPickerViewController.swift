//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Tom Murray on 11/01/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import Foundation
import UIKit

class CategoryPickerViewController: UITableViewController {
	
	//Global Vari's
	var selectedCategoryName = ""
	var selectedIndexPath = IndexPath()
	
	
	let categories = [
		"No Category",
		"Apple Store",
		"Bar",
		"Bookstore",
		"Club",
		"Grocery Store",
		"Hoistric Building",
		"House",
		"Ice cream vendor",
		"Landmark",
		"Park"
	]
	
	//Functions
	override func viewDidLoad() {
		super.viewDidLoad()
		
		for i in 0..<categories.count {
			if categories[i] == selectedCategoryName {
				selectedIndexPath = IndexPath(row: i, section: 0)
				break
			}
		}
	}
	
	
	//MARK:- TableViewDelegates
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categories.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		
		let categoryName = categories[indexPath.row]
		cell.textLabel!.text = categoryName
		
		if categoryName == selectedCategoryName {
			cell.accessoryType = .checkmark
		} else {
			cell.accessoryType = .none
		}
		let selection = UIView(frame: CGRect.zero)
		selection.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
		cell.selectedBackgroundView = selection
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row != selectedIndexPath.row {
			if let newCell = tableView.cellForRow(at: indexPath) {
				newCell.accessoryType = .checkmark
			}
			if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
				oldCell.accessoryType = .none
			}
			selectedIndexPath = indexPath
		}
	}

	
	//MARK:- Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "PickedCategory" {
			let cell = sender as! UITableViewCell
			if let indexPath = tableView.indexPath(for: cell) {
				selectedCategoryName = categories[indexPath.row]
			}
		}
	}
}


