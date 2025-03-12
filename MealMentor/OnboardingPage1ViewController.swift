//
//  OnboardingPage1ViewController.swift
//  MealMentor
//
//  Created by Bowen Huang on 3/9/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class OnboardingPage1ViewController: UIViewController {
    
    let userDoc = db.collection("users").document(Auth.auth().currentUser!.uid)
    
    let buttonColor : UIColor = hexStringToUIColor(hex: "#0DB1AD", alphaVal: 0.25)
    
    let lightGrayColor : UIColor = hexStringToUIColor(hex: "#9A9A9A", alphaVal: 0.25)
    
    @IBOutlet weak var maleButton: UIButton!
    
    @IBOutlet weak var femaleButton: UIButton!
    
    @IBOutlet weak var noneButton: UIButton!
    
    @IBOutlet weak var heightSlider: UISlider!
    
    @IBOutlet weak var weightSlider: UISlider!
    
    @IBOutlet weak var ageSlider: UISlider!
    
    @IBOutlet weak var heightSwitch: UISwitch!
    
    @IBOutlet weak var heightTitleLabel: UILabel!
    
    @IBOutlet weak var heightMin: UILabel!
    
    @IBOutlet weak var heightMax: UILabel!
    @IBOutlet weak var weightSwitch: UISwitch!
    
    @IBOutlet weak var weightTitleLabel: UILabel!
    @IBOutlet weak var weightMin: UILabel!
    @IBOutlet weak var weightMax: UILabel!
    @IBOutlet weak var ageSwitch: UISwitch!
    
    @IBOutlet weak var ageTitleLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var ageMin: UILabel!
    
    @IBOutlet weak var ageMax: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let defaultHeight = userDoc.value(forKey: "height")
//        let defaultWeight = userDoc.value(forKey: "weight")
//        let defaultAge = userDoc.value(forKey: "age")
//        let defaultGender = userDoc.value(forKey: "gender")
//        
//        if defaultHeight as! Int != 0 {
//            
//        }
        
        heightSlider.isContinuous = true
        weightSlider.isContinuous = true
        ageSlider.isContinuous = true
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func maleButtonPressed(_ sender: Any) {
        if isUserLoggedIn() {
            updateDocument(doc: userDoc, category: "gender", value: "male")
            self.maleButton.backgroundColor = self.buttonColor
            self.femaleButton.backgroundColor = self.lightGrayColor
            self.noneButton.backgroundColor = self.lightGrayColor
        }
    }
    
    @IBAction func femaleButtonPressed(_ sender: Any) {
        if isUserLoggedIn() {
            updateDocument(doc: userDoc, category: "gender", value: "female")
            self.femaleButton.backgroundColor = self.buttonColor
            self.maleButton.backgroundColor = self.lightGrayColor
            self.noneButton.backgroundColor = self.lightGrayColor
        }
    }
    
    @IBAction func noneButtonPressed(_ sender: Any) {
        if isUserLoggedIn() {
            updateDocument(doc: userDoc, category: "gender", value: "none")
            self.noneButton.backgroundColor = self.buttonColor
            self.femaleButton.backgroundColor = self.lightGrayColor
            self.maleButton.backgroundColor = self.lightGrayColor
        }
    }
    
    @IBAction func heightSwitchAction(_ sender: Any) {
        if heightSwitch.isOn {
            updateDocument(doc: userDoc, category: "height", value: Int(heightSlider.value))
            heightSlider.isEnabled = true
            heightSlider.isContinuous = true
            heightLabel.textColor = UIColor.black
            heightTitleLabel.textColor = UIColor.black
            heightMin.textColor = UIColor.black
            heightMax.textColor = UIColor.black
        } else {
            updateDocument(doc: userDoc, category: "height", value: 0)
            heightSlider.isEnabled = false
            heightLabel.textColor = UIColor.lightGray
            heightTitleLabel.textColor = UIColor.lightGray
            heightMin.textColor = UIColor.lightGray
            heightMax.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func weightSwitchAction(_ sender: Any) {
        if weightSwitch.isOn {
            updateDocument(doc: userDoc, category: "weight", value: Int(weightSlider.value))
            weightSlider.isEnabled = true
            weightSlider.isContinuous = true
            weightLabel.textColor = UIColor.black
            weightTitleLabel.textColor = UIColor.black
            weightMin.textColor = UIColor.black
            weightMax.textColor = UIColor.black
        } else {
            updateDocument(doc: userDoc, category: "weight", value: 0)
            weightSlider.isEnabled = false
            weightLabel.textColor = UIColor.lightGray
            weightTitleLabel.textColor = UIColor.lightGray
            weightMin.textColor = UIColor.lightGray
            weightMax.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func ageSwitchAction(_ sender: Any) {
        if ageSwitch.isOn {
            updateDocument(doc: userDoc, category: "age", value: Int(ageSlider.value))
            ageSlider.isEnabled = true
            ageSlider.isContinuous = true
            ageLabel.textColor = UIColor.black
            ageTitleLabel.textColor = UIColor.black
            ageMin.textColor = UIColor.black
            ageMax.textColor = UIColor.black
        } else {
            updateDocument(doc: userDoc, category: "age", value: 0)
            ageSlider.isEnabled = false
            ageLabel.textColor = UIColor.lightGray
            ageTitleLabel.textColor = UIColor.lightGray
            ageMin.textColor = UIColor.lightGray
            ageMax.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func heightSliderAction(_ sender: Any) {
        updateDocument(doc: userDoc, category: "height", value: Int(heightSlider.value))
        let newHeightFeet:Int = Int(heightSlider.value / 12)
        let newHeightInches:Int = Int(heightSlider.value) % 12
        heightLabel.text = #"\#(newHeightFeet)' \#(newHeightInches)""#
        
    }
    
    @IBAction func weightSliderAction(_ sender: Any) {
        updateDocument(doc: userDoc, category: "weight", value: Int(weightSlider.value))
        weightLabel.text = "\(Int(weightSlider.value))lbs"
    }
    
    @IBAction func ageSliderAction(_ sender: Any) {
        updateDocument(doc: userDoc, category: "age", value: Int(ageSlider.value))
        ageLabel.text = "\(Int(ageSlider.value))"
    }
    
}
