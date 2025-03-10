//
//  LogEntryViewController.swift
//  MealMentor
//
//  Created by Gina Jeon on 3/6/25.
//

import UIKit
import Firebase
import FirebaseAuth

class LogEntryViewController: UIViewController {
    var foodList: [Food] = []
    let defaultCategory = "Breakfast"
    var currentUserId: String? // Replace with actual user ID retrieval logic
    @IBOutlet weak var logTextField: UITextField!
    
    @IBOutlet weak var mealLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUserId = getUserID()
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
            // Print raw response data for debugging
            let rawResponse = String(data: data, encoding: .utf8) ?? "Invalid response data"
            print("RAW API RESPONSE START")
            print(rawResponse)
            print("RAW API RESPONSE END")
            
            // First-level parsing
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
            
            // Get first choice
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
            print("🔍 Extracted JSON string:", jsonString ?? "nil")
            
            guard let jsonData = jsonString?.data(using: .utf8) else {
                showError("Invalid JSON encoding")
                print("FAILED TO CONVERT JSON STRING TO DATA")
                return
            }
            
            // Parse food JSON
            let foodDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            print("Parsed food dictionary:", foodDict ?? "nil")
            
            // Clean data
            guard let cleanedDict = cleanNutritionData(foodDict) else {
                showError("Missing required fields")
                print("FAILED TO CLEAN NUTRITION DATA")
                return
            }
            
            print("Cleaned nutrition data:", cleanedDict)
            
            // Create Food object
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
    // MARK: - JSON Handling
       private func extractJSONString(from text: String) -> String? {
           // Handle markdown code blocks
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
        
        // Handle quantity conversion
        if let quantity = dict["quantity"] as? String {
            print("Original quantity string:", quantity)
            let numericString = quantity.filter { $0.isNumber }
            dict["quantity"] = Int(numericString)
            print("Converted quantity:", dict["quantity"] ?? "conversion failed")
        }
        
        // Ensure all numbers are Int
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
            category: defaultCategory,
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
        showTemporaryMessage("Meal saved successfully!")
    }
    
       private func updateMealLabel() {
           var labelText = "Current Meal (\(defaultCategory)):\n"
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
}
