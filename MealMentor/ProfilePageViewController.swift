//
//  ProfilePageViewController.swift
//  MealMentor
//
//  Created by Bowen Huang on 3/4/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfilePageViewController: ImagePicker {
    
    
    let userDoc = db.collection("users").document(Auth.auth().currentUser!.uid)
    
    @IBOutlet weak var fullName: UILabel!
    
    @IBOutlet weak var gender: UILabel!
    
    @IBOutlet weak var age: UILabel!
    
    @IBOutlet weak var weight: UILabel!
    
    @IBOutlet weak var height: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        currentUserId = getUserID()
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
            print("Sign out error")
        }
    }
    
    @IBAction func uploadButtonTapped(_ sender: Any) {
        presentImagePicker()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            //uploadImage(selectedImage)
        }
        dismiss(animated: true)
    }
}
