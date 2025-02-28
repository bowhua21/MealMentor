//
//  HomePageViewController.swift
//  MealMentor
//
//  Created by Gina Jeon on 2/23/25.
//

import UIKit

class HomePageViewController: UIViewController {
    
    @IBOutlet weak var username: UILabel!
    
    var userName:String = "Jane Doe"
    
    @IBOutlet weak var highlightsView: UIView!
    @IBOutlet weak var thisWeekView: UIView!
    @IBOutlet weak var todayMealsView: UIView!
    @IBOutlet weak var weeklyProteinView: UIView!
    @IBOutlet weak var weeklyCaloriesView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username.text = userName
        // Do any additional setup after loading the view.
        // TODO set username
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // put rounded corners for cells
        highlightsView.layer.cornerRadius = 20
        thisWeekView.layer.cornerRadius = 20
        todayMealsView.layer.cornerRadius = 20
        weeklyProteinView.layer.cornerRadius = 20
        weeklyCaloriesView.layer.cornerRadius = 20
    }
}
