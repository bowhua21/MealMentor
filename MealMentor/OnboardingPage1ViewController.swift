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
    
    let buttonColor : UIColor = hexStringToUIColor(hex: "#0DB1AD", alphaVal: 1.00)
    
    let lightGrayColor : UIColor = hexStringToUIColor(hex: "#636363", alphaVal: 0.50)
    
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
        
        maleButton.layer.cornerRadius = 10
        maleButton.backgroundColor = lightGrayColor
        
        femaleButton.layer.cornerRadius = 10
        femaleButton.backgroundColor = lightGrayColor
        
        noneButton.layer.cornerRadius = 10
        noneButton.backgroundColor = buttonColor
        
        if isUserLoggedIn() {
            ProfileLoader().loadProfile { profile in
                if profile.gender == "male" {
                    self.maleButton.backgroundColor = self.buttonColor
                    self.noneButton.backgroundColor = self.lightGrayColor
                } else if profile.gender == "female" {
                    self.femaleButton.backgroundColor = self.buttonColor
                    self.noneButton.backgroundColor = self.lightGrayColor
                }
                if profile.age != nil && profile.age != 0 {
                    self.ageSlider.value = Float(profile.age!)
                    self.ageLabel.text = "\(Int(self.ageSlider.value))"
                    
                }
                if profile.weight != nil && profile.weight != 0 {
                    self.weightSlider.value = Float(profile.weight!)
                    self.weightLabel.text = "\(Int(self.weightSlider.value))lbs"
                }
                if profile.height != nil && profile.height != 0 {
                    self.heightSlider.value = Float(profile.height!)
                    self.heightLabel.text = profile.heightFormatted
                }
                
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func setBackgroundColor(color: UIColor, button: UIButton) {
        UIView.animate(withDuration: 0.25, animations: {
            button.backgroundColor = color
        })
    }
    
    @IBAction func maleButtonPressed(_ sender: Any) {
        if isUserLoggedIn() {
            updateDocument(doc: userDoc, category: "gender", value: "male")
            setBackgroundColor(color: self.buttonColor, button: maleButton)
            setBackgroundColor(color: self.lightGrayColor, button: femaleButton)
            setBackgroundColor(color: self.lightGrayColor, button: noneButton)
        }
    }
    
    @IBAction func femaleButtonPressed(_ sender: Any) {
        if isUserLoggedIn() {
            updateDocument(doc: userDoc, category: "gender", value: "female")
            setBackgroundColor(color: self.buttonColor, button: femaleButton)
            setBackgroundColor(color: self.lightGrayColor, button: maleButton)
            setBackgroundColor(color: self.lightGrayColor, button: noneButton)
        }
    }
    
    @IBAction func noneButtonPressed(_ sender: Any) {
        if isUserLoggedIn() {
            updateDocument(doc: userDoc, category: "gender", value: "none")
            setBackgroundColor(color: self.buttonColor, button: noneButton)
            setBackgroundColor(color: self.lightGrayColor, button: femaleButton)
            setBackgroundColor(color: self.lightGrayColor, button: maleButton)
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
