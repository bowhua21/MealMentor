//
//  LogDisplayViewController.swift
//  MealMentor
//
//  Created by Yingting Cao on 3/9/25.
//

import UIKit
import FirebaseFirestore

class LogDisplayViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    let breakfastCellIdentifier = "breakfastCell"
    var breakfast: Meal?
    var lunch: Meal?
    var dinner: Meal?
    var snack: Meal?
    
    @IBOutlet weak var breakfastTableView: UITableView!
    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return breakfast?.foodList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: breakfastCellIdentifier, for: indexPath)
        if let eachFood = breakfast?.foodList[indexPath.row] {
            cell.textLabel?.text = eachFood.name
        }
        return cell
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBreakfastTableView()
    }
    
    private func setupBreakfastTableView() {
        breakfastTableView.delegate = self
        breakfastTableView.dataSource = self
    }
    
}
