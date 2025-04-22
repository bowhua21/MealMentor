//
//  ProfilePageViewController.swift
//  MealMentor
//
//  Created by Bowen Huang on 3/4/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfilePageViewController: DarkModeViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    
    let userDoc = db.collection("users").document(Auth.auth().currentUser!.uid)
    
    
    @IBOutlet weak var fullName: UILabel!
    
    @IBOutlet weak var gender: UILabel!
    
    @IBOutlet weak var age: UILabel!
    
    @IBOutlet weak var weight: UILabel!
    
    @IBOutlet weak var height: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imageURL:String!
    
    var profilePic : UIImage!
    
    var currentUserId: String?

    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        currentUserId = getUserID()

        //imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        
        ProfileLoader().loadProfile { profile in
            self.fullName.text = profile.fullName
            self.gender.text = profile.gender
            self.age.text = profile.age != nil ? "\(profile.age!)" : ""
            self.weight.text = profile.weight != nil ? "\(profile.weight!) lbs" : ""
            self.height.text = profile.heightFormatted
        }
        
        fetchProfilePictureURL()

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
            uploadImage(selectedImage)
        }
        dismiss(animated: true)
    }
    
    func fetchProfilePictureURL() {
        guard let uid = Auth.auth().currentUser?.uid else {
            present(errorAlertController(title: "Error", message: "Sign into profile"), animated: true)
            return
        }
        db.collection("user_photos")
            .whereField("userId",    isEqualTo: uid)
            .whereField("category",  isEqualTo: "Profile Picture")
            .getDocuments { [weak self] snap, error in
                guard let self = self else { return }
                if let error = error {
                    present(errorAlertController(title: "Error", message: "Fetch error: \(error.localizedDescription)"), animated: true)
                    return
                }
                let docs = snap?.documents ?? []
                guard !docs.isEmpty else {
                    return
                }
                imageURL = docs.compactMap {
                    $0.data()["imageUrl"] as? String
                }[0]
                if imageURL == nil || imageURL == "" {
                    return
                }
                downloadImage(urlString: imageURL)
            }
    }
    
    func downloadImage(urlString : String) {
        let group = DispatchGroup()
        group.enter()
        let ref = Storage.storage().reference(forURL: urlString)
        ref.getData(maxSize: 10 * 4096 * 4096) { [weak self] data, error in
            defer { group.leave() }
            guard let self = self else { return }
            if let data = data, let img = UIImage(data: data) {
                profilePic = img
            } else {
                print("image download failed:", error?.localizedDescription ?? "")
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            if self.profilePic == nil {
                present(errorAlertController(title: "Error", message: "Failed to load picture"), animated: true)
            } else {
                self.showImage(imageURL: urlString)
            }
        }
    }
    
    func showImage(imageURL : String) {
        let storageRef = Storage.storage().reference(forURL: imageURL)
        
        storageRef.getData(maxSize: 10 * 4096 * 4096) { [weak self] data, error in
            if let err = error {
                print("Storage download error:", err.localizedDescription)
                return
            }
            guard let data = data,
                  let img = UIImage(data: data) else {
                print("Invalid image data")
                return
            }
            DispatchQueue.main.async {
                self?.imageView.image = img
            }
        }
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
    

    func uploadImage(_ image: UIImage) {
        guard let uid = currentUserId else {
            present(errorAlertController(title: "Error", message: "Sign in to upload images"), animated: true)
            return
        }
        let storageRef = Storage.storage().reference()
        let filename = "\(uid)_\(UUID().uuidString).jpg"
        let imgRef = storageRef.child("user_images/\(filename)")
        guard let data = image.jpegData(compressionQuality: 0.75) else {
            present(errorAlertController(title: "Error", message: "Image processing failed"), animated: true)
            return
        }
        
        let _ = imgRef.putData(data, metadata: nil) { [weak self] _, error in
            guard let self = self else { return }

            if let err = error {
                present(errorAlertController(title: "Error", message: "Upload failed: \(err.localizedDescription)"), animated: true)
                return
            }
            
            imgRef.downloadURL { url, error in
                if let err = error {
                    self.present(errorAlertController(title: "Error", message: "URL retrieve failed: \(err.localizedDescription)"), animated: true)
                    return
                }
                guard let url = url else {
                    self.present(errorAlertController(title: "Error", message: "Invalid download URL"), animated: true)
                    return
                }
                Task {
                    await self.saveImageURLToFirestore(url)
                }
                //self.saveImageURLToFirestore(url)
            }
        }
    }
    
    func saveImageURLToFirestore(_ url: URL) async {
        guard let uid = currentUserId else {
            return
        }
        print("saving now: \(url.absoluteString)")
        let photoDocument = db.collection("user_photos").document(Auth.auth().currentUser!.uid)
        if await docExists(docName: "user_photos", docId: uid) {
            updateDocument(doc: photoDocument, category: "imageUrl", value: url.absoluteString)
        } else {
              let photoDoc: [String: Any] = [
                "imageUrl":   url.absoluteString,
                "uploadedAt": Timestamp(date: Date()),
                "userId":     uid,
                "category":   "Profile Picture",
              ]
              
              
              db.collection("user_photos").document(uid).setData(photoDoc) { error in
                  if let error = error {
                      print("Firestore error saving URL:", error.localizedDescription)
                  } else {
                      print("Saved image URL to Firestore as a new meal doc")
                  }
              }
          }

    }
    
}
