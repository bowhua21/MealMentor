//
//  LogHistoryFoodGalleryViewController.swift
//  MealMentor
//
//  Created by Gina Jeon on 4/21/25.
//


import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class LogHistoryFoodGalleryViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var selectedCategory: MealCategory = .breakfast
    var selectedDate: Date?
    private var imageURLs = [String]()
    private var images    = [UIImage]()
    private var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showImage(index: 0)
        fetchImagesForSelectedDate()
    }
    
    func fetchImagesForSelectedDate() {
        guard let uid = Auth.auth().currentUser?.uid else {
            label.text = "Please sign in to view photos."
            return
        }
        
        guard let date = selectedDate else {
            label.text = "No date selected."
            return
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let db = Firestore.firestore()
        db.collection("user_photos")
            .whereField("userId", isEqualTo: uid)
            .whereField("category", isEqualTo: selectedCategory.rawValue)
            .whereField("uploadedAt", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("uploadedAt", isLessThan: Timestamp(date: endOfDay))
            .getDocuments { [weak self] snap, error in
                guard let self = self else { return }
                if let error = error {
                    self.label.text = "Fetch error: \(error.localizedDescription)"
                    return
                }
                let docs = snap?.documents ?? []
                guard !docs.isEmpty else {
                    self.label.text = "No photos uploaded on this date."
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
