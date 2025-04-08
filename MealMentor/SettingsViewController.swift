//
//  SettingsViewController.swift
//  MealMentor
//
//  Created by Bowen Huang on 3/4/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SettingsViewController: DarkModeViewController {

    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    @IBOutlet weak var verboseChatResponsesSwitch: UISwitch!
    
    let userDoc = db.collection("users").document(Auth.auth().currentUser!.uid)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDocumentData(from: userDoc, category: "darkMode") { value, error in
            if let error = error {
                print("Error fetching field: \(error.localizedDescription)")
            } else if let darkMode = value as? Bool {
                self.darkModeSwitch.setOn(darkMode, animated: false)
//                self.isUserDarkModeOn = darkMode
//                print("in get doc data darkMode: \(darkMode), isUserDarkMode: \(self.isUserDarkModeOn)")
            } else {
                print("Field does not exist")
            }
        }
        //        getDocumentData(from: userDoc, category:  "verboseResponsePreference") { value, error in
//            if let error = error {
//                print("Error fetching field: \(error.localizedDescription)")
//            } else {
//                self.verboseChatResponsesSwitch.isOn = value as? Bool ?? false
//            }
//        }
    }
    
    @IBAction func darkModeToggle(_ sender: Any) {
        updateDocument(doc: userDoc, category: "darkMode", value: darkModeSwitch.isOn)
        setTheme()
        //UserDefaults.standard.set(darkModeSwitch.isOn, forKey: "prefs_is_dark_mode_on")
        //overrideUserInterfaceStyle = darkModeSwitch.isOn ? .dark : .light
    }
    

    @IBAction func onChatResponsePreferenceChanged(_ sender: Any) {
        updateDocument(doc: userDoc, category: "verboseResponsePreference", value: verboseChatResponsesSwitch.isOn)
       
    }
}
