//
//  LogEntryViewController.swift
//  MealMentor
//
//  Created by Gina Jeon on 3/6/25.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

protocol LogEntryViewControllerDelegate: AnyObject {
    func didSaveMeal()
}


class LogEntryViewController: DarkModeViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var mealTitleLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    let loadingIndicator = LoadingIndicatorView()
    var selectedCategory: MealCategory = .breakfast
    weak var delegate: LogEntryViewControllerDelegate?
    var foodList: [Food] = []
    var currentUserId: String?
    @IBOutlet weak var logTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mealLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUserId = getUserID()
        imagePicker.delegate = self
        
        if (selectedCategory == .breakfast) {
            mealTitleLabel.text = "Breakfast"
        } else if (selectedCategory == .lunch) {
            mealTitleLabel.text = "Lunch"
        } else if (selectedCategory == .dinner) {
            mealTitleLabel.text = "Dinner"
        } else {
            mealTitleLabel.text = "Snack"
        }
        
        setupLoadingIndicator()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logTextField.layer.cornerRadius = logTextField.frame.height / 2
        logTextField.clipsToBounds = true
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 50),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        loadingIndicator.isHidden = true
    }
    
    private func showLoading() {
        view.bringSubviewToFront(loadingIndicator)
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        logTextField.isEnabled = false // Prevent input while loading
    }
    
    private func hideLoading() {
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
        logTextField.isEnabled = true
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
    
    func generateNutritionPrompt(for foodItem: String) -> String {
        let instruction = """
            Format the food item into JSON with EXACTLY these keys and INTEGER values:
            {
              "name": "string",
              "quantity": number (grams without units),
              "calories": integer,
              "protein": integer,
              "carbohydrates": integer,
              "fat": integer,
              "fiber": integer,
              "vitaminA": integer,
              "vitaminC": integer
            }
            Example:
            {
              "name": "grilled chicken",
              "quantity": 150,
              "calories": 239,
              "protein": 44,
              "carbohydrates": 0,
              "fat": 5,
              "fiber": 0,
              "vitaminA": 2,
              "vitaminC": 0
            }
            Input: 
            """
        return instruction + foodItem
    }
    
    func getDeepSeekAPIKey() -> String? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path) as? [String: Any],
              let deepSeekAPIKey = config["DeepSeekAPIKey"] as? String else {
            print("Error: Could not load DeepSeekAPIKey from Config.plist")
            return nil
        }
        return deepSeekAPIKey
    }
    
    @IBAction func finishLogClicked(_ sender: Any) {
        saveCompleteMeal()
    }
    
    @IBAction func addClicked(_ sender: Any) {
        guard let text = logTextField.text, !text.isEmpty else { return }
        showLoading()
        let prompt = generateNutritionPrompt(for: text)
        sendToDeepSeek(prompt: prompt)
    }
    private func processFoodInput() {
        guard let text = logTextField.text, !text.isEmpty else {
            showError("Please enter a food item")
            return
        }
        let prompt = generateNutritionPrompt(for: text)
        sendToDeepSeek(prompt: prompt)
    }
    
    private func sendToDeepSeek(prompt: String) {
        guard let url = URL(string: "https://api.deepseek.com/v1/chat/completions"),
              let apiKey = getDeepSeekAPIKey() else {
            showError("API configuration error")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [["role": "user", "content": prompt]],
            "temperature": 0.3
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            showError("Request creation failed")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showError("API Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                self.showError("No data received")
                return
            }
            
            self.handleAPIResponse(data: data)
        }.resume()
    }
    private func handleAPIResponse(data: Data) {
        // Always hide loading indicator when processing completes
        defer {
            DispatchQueue.main.async { [weak self] in
                self?.hideLoading()
            }
        }
        
        do {
            // Debug raw response
            let rawResponse = String(data: data, encoding: .utf8) ?? "Invalid response data"
            print("API Response Raw:\n\(rawResponse)")
            
            // Parse root JSON
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                showError("Invalid API response format")
                return
            }
            
            // Check for API errors first
            if let apiError = json["error"] as? [String: Any] {
                let errorMessage = apiError["message"] as? String ?? "Unknown API error"
                showError("API Error: \(errorMessage)")
                return
            }
            
            // Extract response content
            guard let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let responseText = message["content"] as? String else {
                showError("Invalid response structure")
                return
            }
            
            print("API Response Content:\n\(responseText)")
            
            // Extract JSON from response text
            guard let jsonString = extractJSONString(from: responseText),
                  let jsonData = jsonString.data(using: .utf8) else {
                showError("Could not find nutrition data in response")
                return
            }
            
            // Parse food data
            guard let foodDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                  let cleanedDict = cleanNutritionData(foodDict),
                  let food = Food.fromDictionary(cleanedDict) else {
                showError("Invalid nutrition data format")
                return
            }
            
            // Update UI with new food item
            DispatchQueue.main.async { [weak self] in
                self?.handleNewFoodItem(food)
            }
            
        } catch {
            showError("Failed to process response: \(error.localizedDescription)")
            print("Parsing Error: \(error)")
            if let decodingError = error as? DecodingError {
                print("Decoding Error Details: \(decodingError)")
            }
        }
    }
    
    private func extractJSONString(from text: String) -> String? {
        let pattern = "```(?:json)?\\s*([\\s\\S]*?)\\s*```"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        guard let match = matches.first else {
            return text.range(of: "\\{.*\\}", options: .regularExpression).map { String(text[$0]) }
        }
        
        let jsonRange = Range(match.range(at: 1), in: text)!
        return String(text[jsonRange])
    }
    
    
    private func cleanNutritionData(_ dict: [String: Any]?) -> [String: Any]? {
        guard var dict = dict else {
            print("Nutrition data is nil")
            return nil
        }
        
        if let quantity = dict["quantity"] as? String {
            print("Original quantity string:", quantity)
            let numericString = quantity.filter { $0.isNumber }
            dict["quantity"] = Int(numericString)
            print("Converted quantity:", dict["quantity"] ?? "conversion failed")
        }
        
        let numberKeys = ["quantity", "calories", "protein", "carbohydrates",
                          "fat", "fiber", "vitaminA", "vitaminC"]
        
        for key in numberKeys {
            if let value = dict[key] as? Double {
                print("Converting \(key) from Double (\(value)) to Int")
                dict[key] = Int(value)
            }
        }
        
        print("Cleaned nutrition data:", dict)
        return dict
    }
    
    private func handleNewFoodItem(_ food: Food) {
        foodList.append(food)
        logTextField.text = ""
        updateMealLabel()
        showTemporaryMessage("Added: \(food.name)")
        print("Added food: \(food.name)")
    }
    
    private func saveCompleteMeal() {
        guard !foodList.isEmpty else {
            showError("Please add at least one food item")
            print("Attempted to save empty meal")
            return
        }
        
        print("Saving complete meal with \(foodList.count) items:")
        foodList.forEach { print("- \($0.name) (\($0.quantity)g)") }
        
        let meal = Meal(
            date: Date(),
            userID: currentUserId!,
            category: selectedCategory.rawValue,
            foodList: foodList
        )
        
        let db = Firestore.firestore()
        db.collection("meals").addDocument(data: meal.toDictionary()) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError("Save failed: \(error.localizedDescription)")
                    print("Firestore save error:", error.localizedDescription)
                } else {
                    print("Meal saved successfully to Firestore")
                    self?.handleSuccessfulSave()
                }
            }
        }
    }
    
    private func handleSuccessfulSave() {
        print("Resetting meal list after successful save")
        foodList.removeAll()
        logTextField.text = ""
        updateMealLabel()
        delegate?.didSaveMeal()
        showTemporaryMessage("Meal saved successfully!")
    }
    
    private func updateMealLabel() {
        let categoryName: String
        switch selectedCategory {
        case .breakfast:
            categoryName = "breakfast"
        case .lunch:
            categoryName = "lunch"
        case .dinner:
            categoryName = "dinner"
        case .snack:
            categoryName = "snacks"  // Maps "snack" category to "snacks" label
        }
        
        var labelText = "Current Meal (\(categoryName)):\n"
        labelText += foodList.isEmpty ? "No items added yet" : foodList.enumerated().map {
            "\($0+1). \($1.name) (\($1.quantity)g)"
        }.joined(separator: "\n")
        mealLabel.text = labelText
    }
    
    
    private func showTemporaryMessage(_ message: String) {
        let originalText = mealLabel.text ?? ""
        mealLabel.text = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.mealLabel.text = originalText
        }
    }
    
    private func showError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.mealLabel.text = message
        }
    }
    @IBAction func uploadButtonTapped(_ sender: Any) {
        presentImagePicker()
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            uploadImage(selectedImage)
        }
        dismiss(animated: true)
    }
    
    func uploadImage(_ image: UIImage) {
        guard let currentUserId = currentUserId else {
            showError("Please sign in to upload images")
            return
        }

        showLoading()
        
        let storageRef = Storage.storage().reference()
        let imageName = "\(currentUserId)_\(UUID().uuidString).jpg"
        let imageRef = storageRef.child("user_images/\(imageName)")
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            hideLoading()
            showError("Failed to process image")
            return
        }
        
        let uploadTask = imageRef.putData(imageData, metadata: nil) { [weak self] metadata, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoading()
                // not working for now
                
//                if let error = error {
//                    self.showError("Upload failed: \(error.localizedDescription)")
//                    return
//                }
                
//                imageRef.downloadURL { url, error in
//                    if let error = error {
//                        self.showError("Failed to get URL: \(error.localizedDescription)")
//                        return
//                    }
//                    
//                    guard let downloadURL = url else {
//                        self.showError("Invalid image URL")
//                        return
//                    }
//                    
//                    self.saveImageURLToFirestore(url: downloadURL)
//                    self.showTemporaryMessage("Image uploaded successfully!")
//                }
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Upload progress: \(percentComplete)%")
        }
    }
    
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
}
