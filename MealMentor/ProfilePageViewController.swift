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

        getDocumentData(from: userDoc, category: "firstName") { value, error in
            if let error = error {
                print("Error fetching field: \(error.localizedDescription)")
            } else if let value = value {
                print("Fetched field value: \(value)")
                self.fullName.text = value as? String
            } else {
                print("Field does not exist")
            }
        }
        
        getDocumentData(from: userDoc, category: "lastName") { value, error in
            if let error = error {
                print("Error fetching field: \(error.localizedDescription)")
            } else if let value = value {
                print("Fetched field value: \(value)")
                let last : String = (value as? String)!
                self.fullName.text = self.fullName.text! +  " " + last
            } else {
                print("Field does not exist")
            }
        }
        getDocumentData(from: userDoc, category: "gender") { value, error in
            if let error = error {
                print("Error fetching field: \(error.localizedDescription)")
            } else if let value = value {
                print("Fetched field value: \(value)")
                self.gender.text = value as? String
            } else {
                print("Field does not exist")
            }
        }
        getDocumentData(from: userDoc, category: "age") { value, error in
            if let error = error {
                print("Error fetching field: \(error.localizedDescription)")
            } else if let value = value {
                print("Fetched field value: \(value)")
                let ageNum : Int = (value as? Int)!
                if ageNum == 0 {
                    self.age.text = ""
                } else {
                    self.age.text = "\(ageNum)"
                }
            } else {
                print("Field does not exist")
            }
        }
        getDocumentData(from: userDoc, category: "weight") { value, error in
            if let error = error {
                print("Error fetching field: \(error.localizedDescription)")
            } else if let value = value {
                print("Fetched field value: \(value)")
                let weightNum : Int = (value as? Int)!
                if weightNum == 0 {
                    self.weight.text = ""
                } else {
                    self.weight.text = "\(weightNum) lbs"
                }
            } else {
                print("Field does not exist")
            }
        }
        getDocumentData(from: userDoc, category: "height") { value, error in
            if let error = error {
                print("Error fetching field: \(error.localizedDescription)")
            } else if let value = value {
                print("Fetched field value: \(value)")
                let heightNum : Int = (value as? Int)!
                if heightNum == 0 {
                    self.height.text = ""
                } else {
                    let newHeightFeet:Int = Int(heightNum / 12)
                    let newHeightInches:Int = heightNum % 12
                    self.height.text = #"\#(newHeightFeet)' \#(newHeightInches)""#
                }
            } else {
                print("Field does not exist")
            }
        }//        print("first name: \(getDocumentData(doc: userDoc, category: "firstName"))")
//        print("last name: \(getDocumentData(doc: userDoc, category: "lastName"))")
//        print("age: \(getDocumentData(doc: userDoc, category: "age"))")
//        print("weight: \(getDocumentData(doc: userDoc, category: "weight"))")
//        print("height: \(getDocumentData(doc: userDoc, category: "height"))")
//        print("allergies: \(getDocumentData(doc: userDoc, category: "allergies"))")
//        print("gender: \(getDocumentData(doc: userDoc, category: "gender"))")
        //if dataDescription != "" {
        //    fullName.text = dataDescription[firstName]
        //}

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
