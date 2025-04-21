//
//  FoodGalleryViewController.swift
//  MealMentor
//
//  Created by Yingting Cao on 4/9/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class FoodGalleryViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var selectedCategory: MealCategory = .breakfast
    private var imageURLs = [String]()
    private var images    = [UIImage]()
    private var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showImage(index: 0)
        fetchTodayImages()
    }
    
    func fetchTodayImages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            label.text = "Please sign in to view photos."
            return
        }
        
        label.text = String(selectedCategory.rawValue.dropFirst(4))
        
        let db = Firestore.firestore()
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let today = Timestamp(date: startOfDay)
        
        db.collection("user_photos")
            .whereField("userId",    isEqualTo: uid)
            .whereField("category",  isEqualTo: selectedCategory.rawValue)
            .whereField("uploadedAt", isGreaterThan: today)
            .getDocuments { [weak self] snap, error in
                guard let self = self else { return }
                if let error = error {
                    self.label.text = "Fetch error: \(error.localizedDescription)"
                    return
                }
                let docs = snap?.documents ?? []
                guard !docs.isEmpty else {
                    self.label.text = "No photos uploaded today."
                    return
                }
                self.imageURLs = docs.compactMap {
                    $0.data()["imageUrl"] as? String
                }
                self.downloadAllImages()
            }
    }
    
    func downloadAllImages() {
            let group = DispatchGroup()
            for urlString in imageURLs {
                group.enter()
                let ref = Storage.storage().reference(forURL: urlString)
                ref.getData(maxSize: 5 * 1024 * 1024) { [weak self] data, error in
                    defer { group.leave() }
                    guard let self = self else { return }
                    if let data = data, let img = UIImage(data: data) {
                        self.images.append(img)
                    } else {
                        print("image download failed:", error?.localizedDescription ?? "")
                    }
                }
            }
            group.notify(queue: .main) { [weak self] in
                guard let self = self else { return }
                if self.images.isEmpty {
                    self.label.text = "Failed to load images."
                } else {
                    self.currentIndex = 0
                    self.showImage(index: 0)
                }
            }
        }
    

    @IBAction func onResetButton(_ sender: Any) {
        showImage(index: 0)
        currentIndex = 0
    }
    @IBAction func onNextButton(_ sender: Any) {
        currentIndex = (currentIndex + 1) % images.count
        showImage(index: currentIndex)
        
    }
    @IBAction func onPreviousButton(_ sender: Any) {
        currentIndex = (currentIndex + images.count - 1) % images.count
        showImage(index: currentIndex)
    }
    
    func showImage(index: Int) {
        guard index < imageURLs.count else { return }
        let imageUrl = imageURLs[index]
        let storageRef = Storage.storage().reference(forURL: imageUrl)
        
        storageRef.getData(maxSize: 5 * 1024 * 1024) { [weak self] data, error in
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        images.removeAll()
        imageURLs.removeAll()
        currentIndex = 0
        imageView.image = nil
        label.text = ""
    }
}
