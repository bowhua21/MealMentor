//
//  ProfilePageViewController.swift
//  MealMentor
//
//  Created by Bowen Huang on 3/4/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfilePageViewController: UIViewController {

    
    let userDoc = db.collection("users").document(Auth.auth().currentUser!.uid)
    
    @IBOutlet weak var fullName: UILabel!
    
    @IBOutlet weak var gender: UILabel!
    
    @IBOutlet weak var age: UILabel!
    
    @IBOutlet weak var weight: UILabel!
    
    @IBOutlet weak var height: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ProfileLoader().loadProfile { profile in
            self.fullName.text = profile.fullName
            self.gender.text = profile.gender
            self.age.text = profile.age != nil ? "\(profile.age!)" : ""
            self.weight.text = profile.weight != nil ? "\(profile.weight!) lbs" : ""
            self.height.text = profile.heightFormatted
        }
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
