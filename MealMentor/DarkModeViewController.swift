//
//  DarkModeViewController.swift
//  MealMentor
//
//  Created by Bowen Huang on 4/7/25.
//

import UIKit

class DarkModeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()
      // Do any additional setup after loading the view.
    }
    
    private func setTheme() {
        //code copied from https://stackoverflow.com/questions/60577630/i-want-to-make-my-dark-mode-work-across-all-view-controllers-at-the-same-time-us
        let isDarkOn = UserDefaults.standard.bool(forKey: "prefs_is_dark_mode_on") as? Bool ?? true
        overrideUserInterfaceStyle = isDarkOn ? .dark : .light
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
