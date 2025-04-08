//
//  DarkModeViewController.swift
//  MealMentor
//
//  Created by Bowen Huang on 4/7/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class DarkModeViewController: UIViewController {
    
    
    private let userDoc = db.collection("users").document(Auth.auth().currentUser!.uid)
    
    var isUserDarkModeOn : Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()
      // Do any additional setup after loading the view.
    }
    
    func setTheme() {
        //code copied from https://stackoverflow.com/questions/60577630/i-want-to-make-my-dark-mode-work-across-all-view-controllers-at-the-same-time-us
        getDocumentData(from: userDoc, category: "darkMode") { value, error in
            if let error = error {
                print("Error fetching field: \(error.localizedDescription)")
            } else if let darkMode = value as? Bool {
                self.overrideUserInterfaceStyle = darkMode ? .dark : .light
//                self.isUserDarkModeOn = darkMode
//                print("in get doc data darkMode: \(darkMode), isUserDarkMode: \(self.isUserDarkModeOn)")
            } else {
                print("Field does not exist")
            }
        }
        
        //print("debug dark mode: \(isUserDarkModeOn)")
        //let isDarkOn = UserDefaults.standard.bool(forKey: "prefs_is_dark_mode_on") as? Bool ?? true
        //overrideUserInterfaceStyle = isUserDarkModeOn ? .dark : .light
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setTheme()
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
