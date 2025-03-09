//
//  LogEntryViewController.swift
//  MealMentor
//
//  Created by Gina Jeon on 3/6/25.
//

import UIKit
import Firebase



class LogEntryViewController: UIViewController {
    var userInput: String?
    var messages: [ChatMessage] = []
    //let db = Firestore.firestore()
    let currentUserId = "user123" // Replace with actual user ID retrieval logic
    @IBOutlet weak var logTextField: UITextField!
    
    @IBOutlet weak var mealLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func generateNutritionPrompt(for foodItem: String) -> String {
        let instruction = """
        Format the following food item into JSON with these keys:
        name, quantity, calories, protein, carbohydrates, fat, fiber, vitaminA, vitaminC.
        Use numeric values for calories/protein/carbs/fat/fiber, and strings for vitamin percentages.
        Example response:
        {
          "name": "chicken breast",
          "quantity": "200g",
          "calories": 165,
          "protein": 31,
          "carbohydrates": 0,
          "fat": 3.6,
          "fiber": 0,
          "vitaminA": "0",
          "vitaminC": "0"
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
    
    @IBAction func finishClicked(_ sender: Any) {
        guard let text = logTextField.text, !text.isEmpty else { return }
        let prompt = generateNutritionPrompt(for: text)
        sendToDeepSeek(prompt: prompt)
    }
    
    
    func sendToDeepSeek(prompt: String) {
        guard let url = URL(string: "https://api.deepseek.com/v1/chat/completions"),
              let apiKey = getDeepSeekAPIKey() else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [["role": "user", "content": prompt]]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("JSON error: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("API Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            // Print raw response data
            print("Raw API Response:")
            print(String(data: data, encoding: .utf8) ?? "Could not decode response")
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let content = choices.first?["message"] as? [String: Any],
                   let responseText = content["content"] as? String {
                    
                    // Print parsed response text
                    print("\nParsed Response:")
                    print(responseText)
                    
                    DispatchQueue.main.async {
                        self.mealLabel.text = responseText
                    }
                }
            } catch {
                print("Parsing error: \(error)")
            }
        }.resume()
    }
}
