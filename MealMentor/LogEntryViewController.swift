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


class LogEntryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let imagePicker = UIImagePickerController()
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
        do {

            let rawResponse = String(data: data, encoding: .utf8) ?? "Invalid response data"
            print("RAW API RESPONSE START")
            print(rawResponse)
            print("RAW API RESPONSE END")
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                showError("Invalid root JSON structure")
                print("FAILED TO PARSE ROOT JSON OBJECT")
                return
            }
            print("Root JSON parsed successfully")
            print("Root JSON keys: \(json.keys.joined(separator: ", "))")
            
            // Extract choices array
            guard let choices = json["choices"] as? [[String: Any]] else {
                showError("Missing choices array")
                print("MISSING CHOICES ARRAY")
                return
            }
            
            print("Found \(choices.count) choices")
            guard let firstChoice = choices.first else {
                showError("Empty choices array")
                print("EMPTY CHOICES ARRAY")
                return
            }
            
            print("First choice contents:", firstChoice)
            
            // Extract message content
            guard let message = firstChoice["message"] as? [String: Any],
                  let responseText = message["content"] as? String else {
                showError("Invalid message format")
                print("INVALID MESSAGE FORMAT")
                return
            }
            
            print("Extracted response text:")
            print("--- RESPONSE TEXT START ---")
            print(responseText)
            print("--- RESPONSE TEXT END ---")
            
            // Attempt to find JSON in response text
            let jsonString = self.extractJSONString(from: responseText)
            print("Extracted JSON string:", jsonString ?? "nil")
            
            guard let jsonData = jsonString?.data(using: .utf8) else {
                showError("Invalid JSON encoding")
                print("FAILED TO CONVERT JSON STRING TO DATA")
                return
            }
            
            let foodDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            print("Parsed food dictionary:", foodDict ?? "nil")
            guard let cleanedDict = cleanNutritionData(foodDict) else {
                showError("Missing required fields")
                print("FAILED TO CLEAN NUTRITION DATA")
                return
            }
            
            print("Cleaned nutrition data:", cleanedDict)
            guard let food = Food.fromDictionary(cleanedDict) else {
                showError("Failed to create food item")
                print("FAILED TO INITIALIZE FOOD OBJECT")
                print("Problematic dictionary:", cleanedDict)
                return
            }
            
            print("Successfully created Food object:", food)
            DispatchQueue.main.async { [weak self] in
                self?.handleNewFoodItem(food)
            }
            
        } catch {
            showError("Parsing error: \(error.localizedDescription)")
            print("DETAILED PARSING ERROR:", error)
            print("Error context:", error)
            
            if let jsonStr = String(data: data, encoding: .utf8) {
                print("PROBLEMATIC JSON CONTENT:")
                print(jsonStr)
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
    
    // Modify JUST the updateMealLabel function:
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
            
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    self.imagePicker.sourceType = .camera
                    self.present(self.imagePicker, animated: true)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alert, animated: true)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                imageView.image = selectedImage
                uploadImage(selectedImage) // Upload after selecting
            }
            dismiss(animated: true)
        }
        
        func uploadImage(_ image: UIImage) {
            guard let currentUserId = currentUserId else {
                print("No user signed in.")
                return
            }

            let storageRef = Storage.storage().reference()
            let imageRef = storageRef.child("user_images/\(currentUserId)_\(UUID().uuidString).jpg") // Unique name for the image

            // Convert image to data
            guard let imageData = image.jpegData(compressionQuality: 0.75) else {
                print("Error converting image to data")
                return
            }
            
            let uploadTask = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                }
                
                // Once upload is successful, get the download URL
                imageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Error retrieving download URL: \(error.localizedDescription)")
                        return
                    }
                    
                    if let downloadURL = url {
                        print("Image uploaded successfully. URL: \(downloadURL)")
                        // Here you can now save the download URL to Firestore if needed
                        self.saveImageURLToFirestore(url: downloadURL)
                    }
                }
            }
            
            // Optional: track upload progress
            uploadTask.observe(.progress) { snapshot in
                // Handle progress if needed (e.g., update a progress bar)
                print("Upload progress: \(snapshot.progress?.fractionCompleted ?? 0)%")
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
