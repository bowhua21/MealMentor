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

//        getDocumentData(from: userDoc, category:  "verboseResponsePreference") { value, error in
//            if let error = error {
//                print("Error fetching field: \(error.localizedDescription)")
//            } else {
//                self.verboseChatResponsesSwitch.isOn = value as? Bool ?? false
//            }
//        }
    }
    
    @IBAction func darkModeToggle(_ sender: Any) {
        UserDefaults.standard.set(darkModeSwitch.isOn, forKey: "prefs_is_dark_mode_on")
        overrideUserInterfaceStyle = darkModeSwitch.isOn ? .dark : .light
    }
    

    @IBAction func onChatResponsePreferenceChanged(_ sender: Any) {
        updateDocument(doc: userDoc, category: "verboseResponsePreference", value: verboseChatResponsesSwitch.isOn)
       
    }
}
