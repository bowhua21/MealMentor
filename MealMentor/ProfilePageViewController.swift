//
//  ProfilePageViewController.swift
//  MealMentor
//
//  Created by Bowen Huang on 3/4/25.
//

import UIKit
import FirebaseAuth

class ProfilePageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func logoutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            //TODO: error in signing out
            print("Sign out error")
        }
    }
    

}
