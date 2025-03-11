//
//  WelcomePageViewController.swift
//  MealMentor
//
//  Created by Bowen Huang on 3/10/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class WelcomePageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Auth.auth().addStateDidChangeListener() {
            (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "WelcometoHomePageIdentifier", sender: nil)
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WelcometoHomePageIdentifier", let tabBarController = segue.destination as? UITabBarController {
            tabBarController.selectedIndex = 2
            if let homePageNav = tabBarController.viewControllers?[2] as? UINavigationController,
               let homePageVC = homePageNav.topViewController as? HomePageViewController {
                
            }
        }

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
