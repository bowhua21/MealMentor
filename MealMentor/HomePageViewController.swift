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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username.text = userName
        // Do any additional setup after loading the view.
        // TODO set username
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
}
