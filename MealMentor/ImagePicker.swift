//
//  ImagePicker.swift
//  MealMentor
//
//  Created by Bowen Huang on 4/20/25.
//

import UIKit
import Firebase
import FirebaseAuth

class ImagePicker: DarkModeViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    var currentUserId: String?

    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUserId = getUserID()
        imagePicker.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func getUserID() -> String? {
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            print("Current User ID: \(userID)")
            return userID
        } else {
            print("No user is signed in")
            return nil
        }
    }
    
    func presentImagePicker() {
        let alert = UIAlertController(title: "Select Photo", message: nil, preferredStyle: .actionSheet)
        
        // Only show camera option if available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        present(alert, animated: true)
    }
    

//    
//    func uploadImage(_ image: UIImage) {
////        guard let currentUserId = currentUserId else {
////            showError("Please sign in to upload images")
////            return
////        }
//
//        showLoading()
//        
//        let storageRef = Storage.storage().reference()
//        let imageName = "\(currentUserId)_\(UUID().uuidString).jpg"
//        let imageRef = storageRef.child("user_images/\(imageName)")
//        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
//            hideLoading()
//            showError("Failed to process image")
//            return
//        }
//        
//        let uploadTask = imageRef.putData(imageData, metadata: nil) { [weak self] metadata, error in
//            guard let self = self else { return }
//            
//            DispatchQueue.main.async {
//                self.hideLoading()
//                // not working for now
//                
////                if let error = error {
////                    self.showError("Upload failed: \(error.localizedDescription)")
////                    return
////                }
//                
////                imageRef.downloadURL { url, error in
////                    if let error = error {
////                        self.showError("Failed to get URL: \(error.localizedDescription)")
////                        return
////                    }
////
////                    guard let downloadURL = url else {
////                        self.showError("Invalid image URL")
////                        return
////                    }
////
////                    self.saveImageURLToFirestore(url: downloadURL)
////                    self.showTemporaryMessage("Image uploaded successfully!")
////                }
//            }
//        }
//        
//        uploadTask.observe(.progress) { snapshot in
//            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
//            print("Upload progress: \(percentComplete)%")
//        }
//    }
    
    func saveImageURLToFirestore(url: URL) {
        guard let currentUserId = currentUserId else { return }
        
        let db = Firestore.firestore()
        let userImagesRef = db.collection("user_images").document(currentUserId)
        
        // Assuming you're saving an image reference under the user's document
        userImagesRef.setData(["imageURL": url.absoluteString], merge: true) { error in
            if let error = error {
                print("Error saving image URL to Firestore: \(error.localizedDescription)")
            } else {
                print("Image URL saved to Firestore successfully")
            }
        }
    }
    /*
     MARK: - Navigation

     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         Get the new view controller using segue.destination.
         Pass the selected object to the new view controller.
    }
    */

}
