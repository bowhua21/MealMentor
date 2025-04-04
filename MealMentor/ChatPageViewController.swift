//
//  ChatPageViewController.swift
//  MealMentor
//
//  Created by Huyen Nguyen on 2/24/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ChatPageViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var askMealMentorIntroView: UIView!
    @IBOutlet weak var askMealMentorTitleLabel: UILabel!
    @IBOutlet weak var topExamplePromptLabel: UILabel!
    @IBOutlet weak var middleExamplePromptLabel: UILabel!
    @IBOutlet weak var bottomExamplePromptLabel: UILabel!
    @IBOutlet weak var chatInputBar: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatInputBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButtonBottomConstraint: NSLayoutConstraint!
    
    var chatStackView: UIStackView!
    var chatScrollView: UIScrollView!

    let userDoc = db.collection("users").document(Auth.auth().currentUser!.uid)
    var profileData = Profile()
    let lightPurple = UIColor(red: 0.9451, green: 0.9255, blue: 0.9804, alpha: 1.0)
    let darkPurple = UIColor(red: 0.4392, green: 0.2588, blue: 0.7882, alpha: 1.0)
    let currentUserId = Auth.auth().currentUser?.uid
    var messages: [ChatMessage] = []
    var nutritionDataToday: [String: Int] = [:]
    var generateVerboseResponse: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatInputBar.delegate = self
        
        askMealMentorIntroView.layer.cornerRadius = 10
        chatInputBar.backgroundColor = lightPurple
        askMealMentorIntroView.backgroundColor = lightPurple
        askMealMentorTitleLabel.textColor = darkPurple
        topExamplePromptLabel.textColor = darkPurple
        middleExamplePromptLabel.textColor = darkPurple
        bottomExamplePromptLabel.textColor = darkPurple
        
        // setting up the scroll view
        chatScrollView = UIScrollView()
        chatScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chatScrollView)
        
        let scrollViewTopConstraint = NSLayoutConstraint(item: chatScrollView!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 87)
        let scrollViewLeftConstraint = NSLayoutConstraint(item: chatScrollView!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 20)
        let scrollViewRightConstaint = NSLayoutConstraint(item: chatScrollView!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: -20)
        let scrollViewBottomConstraint = NSLayoutConstraint(item: chatScrollView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: chatInputBar!, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: -10)
        view.addConstraints([scrollViewTopConstraint, scrollViewLeftConstraint, scrollViewRightConstaint, scrollViewBottomConstraint])
        
        // setting up the stack view
        chatStackView = UIStackView()
        chatStackView.axis = .vertical
        chatStackView.alignment = .fill
        chatStackView.distribution = .fill
        chatStackView.spacing = 8
        chatStackView.translatesAutoresizingMaskIntoConstraints = false
        chatScrollView.addSubview(chatStackView)
        
        let stackViewTopConstraint = NSLayoutConstraint(item: chatStackView!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: chatScrollView!, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
        let stackViewLeftConstraint = NSLayoutConstraint(item: chatStackView!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: chatScrollView!, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        let stackViewRightConstraint = NSLayoutConstraint(item: chatStackView!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: chatScrollView!, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        let stackViewBottomConstraint = NSLayoutConstraint(item: chatStackView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: chatScrollView!, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        let stackViewWidth = NSLayoutConstraint(item: chatStackView!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: chatScrollView!, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0)
        chatScrollView.addConstraints([stackViewTopConstraint, stackViewLeftConstraint, stackViewRightConstraint, stackViewBottomConstraint, stackViewWidth])

        // setting up keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        fetchChats()
        refetchUserData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        chatInputBar.layer.cornerRadius = chatInputBar.frame.height / 2
        chatInputBar.clipsToBounds = true
        sendButton.backgroundColor = darkPurple
        sendButton.layer.cornerRadius = sendButton.frame.height / 2
        sendButton.clipsToBounds = true
        
        if self.messages.count > 0 {
            self.askMealMentorIntroView.isHidden = true
        }
    }
    
    func refetchUserData() {
        NutritionStats.shared.loadTotalNutritionForToday {
            self.nutritionDataToday = totalNutritionForToday
            print("nutritionDataToday: \(self.nutritionDataToday)")
        }
        getDocumentData(from: userDoc, category:  "verboseResponsePreference") { value, error in
            if let error = error {
                print("Error fetching field: \(error.localizedDescription)")
            } else {
                self.generateVerboseResponse = value as? Bool ?? false
            }
        }
        
        ProfileLoader().loadProfile { profile in
            self.profileData.firstName = profile.firstName
            self.profileData.lastName = profile.lastName
            self.profileData.gender = profile.gender
            self.profileData.age = profile.age
            self.profileData.weight = profile.weight
            self.profileData.height = profile.height
        }
    }
    

    func fetchChats() {
        if (currentUserId == nil) { return }
            
        let oneWeekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        let timestamp = Timestamp(date: oneWeekAgo)
        
        db.collection("chats")
            .whereField("userId", isEqualTo: currentUserId!)
            .whereField("createdAt", isGreaterThan:  timestamp)
            .order(by: "createdAt", descending: false)
            .getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else {
                    self.askMealMentorIntroView.isHidden = false
                    print("Error fetching chats: \(String(describing: error))")
                    return
                }
                
                let documents = snapshot.documents
                
                if documents.isEmpty {
                    self.askMealMentorIntroView.isHidden = false
                } else {
                    self.askMealMentorIntroView.isHidden = true

                    var messagesArray = [ChatMessage]()
                    for doc in documents {
                        let data = doc.data()
                        guard let message = data["message"] as? String,
                              let sender = data["sender"] as? String,
                              let userId = data["userId"] as? String,
                              let createdAt = data["createdAt"] as? Timestamp else {
                            continue
                        }
                        let chatMessage = ChatMessage(userId: userId, message: message, sender: sender, createdAt: createdAt.dateValue())
                        messagesArray.append(chatMessage)
                    }
                    self.messages = messagesArray
                    self.populateChatUI()
                }
        }
    }
    
    func populateChatUI() {
        chatStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for chat in messages {
            let messageContainer = UIStackView()
            messageContainer.axis = .horizontal
            messageContainer.alignment = .fill
            messageContainer.spacing = 8
            messageContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let bubbleLabel = ChatBubble()
            bubbleLabel.text = chat.message
            
            if chat.sender == "user" {
                bubbleLabel.backgroundColor = UIColor.systemGray.withAlphaComponent(0.3)
                bubbleLabel.textAlignment = .right
            } else if chat.sender == "ai" {
                bubbleLabel.backgroundColor = lightPurple
                bubbleLabel.textAlignment = .left
            } else if chat.sender == "error" {
                bubbleLabel.backgroundColor = UIColor.red.withAlphaComponent(0.3)
                bubbleLabel.textAlignment = .center
            }
            
            if chat.sender == "user" {
                let spacer = UIView()
                spacer.translatesAutoresizingMaskIntoConstraints = false
                messageContainer.addArrangedSubview(spacer)
                messageContainer.addArrangedSubview(bubbleLabel)
            } else {
                let spacer = UIView()
                spacer.translatesAutoresizingMaskIntoConstraints = false
                messageContainer.addArrangedSubview(bubbleLabel)
                messageContainer.addArrangedSubview(spacer)
            }
            
            NSLayoutConstraint(item: bubbleLabel, attribute: .width, relatedBy: .lessThanOrEqual, toItem: messageContainer, attribute: .width, multiplier: 0.7, constant: 0).isActive = true
            
            chatStackView.addArrangedSubview(messageContainer)
        }
        scrollToBottom()
    }
    
    func scrollToBottom() {
        DispatchQueue.main.async {
            let bottomOffset = CGPoint(
                x: 0,
                y: max(0, self.chatScrollView.contentSize.height - self.chatScrollView.bounds.height)
            )
            self.chatScrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    func handleSendMessage() {
        if (currentUserId == nil) { return }
        guard let text = chatInputBar.text, !text.isEmpty else { return }
        
        let newChat = [
            "message": text,
            "userId": currentUserId!,
            "createdAt": Timestamp(date: Date()),
            "sender": "user"
        ] as [String : Any]
        
        db.collection("chats").addDocument(data: newChat) { error in
            if let error = error {
                print("Error: \(error)")
                return
            }

            self.chatInputBar.text = ""
            self.messages.append(ChatMessage(userId: self.currentUserId!, message: text, sender: "user", createdAt: Date()))

            DispatchQueue.main.async {
                self.populateChatUI()
                self.sendButton.isEnabled = false
            }
        }
        refetchUserData()
        self.getAIResponse(with: text)
    }
    
    // this function protects the API key by reading from the Config.plist file
    // there should be a row called DeepSeekAPIKey with the api key as the value
    func getDeepSeekAPIKey() -> String? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path) as? [String: Any],
              let deepSeekAPIKey = config["DeepSeekAPIKey"] as? String else {
            print("Error: Could not load DeepSeekAPIKey from Config.plist")
            return nil
        }
        return deepSeekAPIKey
    }
    
    func getAIResponse(with message: String) {
        if (currentUserId == nil) { return }
    
        guard let url = URL(string: "https://api.deepseek.com/chat/completions") else { return }
        guard let apiKey = getDeepSeekAPIKey() else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let chatLengthPreference = generateVerboseResponse ? "Respond in detailed." : "Respond in a 2-3 sentences."
        
        let genderText = (profileData.gender != nil) ? "\nGender: \(profileData.gender ?? "N/A")" : ""
        let heightText = (profileData.heightFormatted != "") ? "\nHeight:  \(profileData.heightFormatted)" : ""
        let weightText = (profileData.weight != nil) ? "\nWeight:  \(profileData.weight ?? 0)" : ""
        let ageText = (profileData.age != nil) ? "\nAge: \(profileData.age ?? 0)" : ""
        
        let todaysNutritionData = "Today's nutrition intake: \n \(nutritionDataToday["calories", default: 0]) calories \n \(nutritionDataToday["protein", default: 0]) grams of protein \n \(nutritionDataToday["carbohydrates", default: 0]) grams of carbs \n \(nutritionDataToday["fat", default: 0]) grams of fat \n \(nutritionDataToday["vitaminA", default: 0]) mcg of Vitamin A \n  \(nutritionDataToday["vitaminC", default: 0]) mcg of Vitamin C \n"
        
        let payload: [String: Any] = [
            "messages": [
                ["role": "system", "content": "You are an assistant for food and nutrition. Please give advice to \(profileData.fullName) based on their data. \(genderText) \(ageText) \(heightText) \(weightText) \n \(todaysNutritionData). You may organize the advice into paragraphs and bullet points but do not use astericks or hashtags. \(chatLengthPreference)"]
                ,
                ["role": "user", "content": message]
            ],
            "model": "deepseek-chat"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            self.sendButton.isEnabled = true
            print("Error serializing JSON: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.sendButton.isEnabled = true
                }
                print("DeepSeek request error: \(error)")
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.sendButton.isEnabled = true
                }
                print("No data received from DeepSeek")
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = jsonResponse["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let deepSeekResponse = message["content"] as? String {
   
                    let newAIChat = [
                        "message": deepSeekResponse,
                        "userId": self.currentUserId!,
                        "createdAt": Timestamp(date: Date()),
                        "sender": "ai"
                    ] as [String: Any]
                    
                    db.collection("chats").addDocument(data: newAIChat) { error in
                        if let error = error {
                            print("Error storing AI response: \(error)")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.messages.append(ChatMessage(userId: self.currentUserId!, message: deepSeekResponse, sender: "ai", createdAt: Date()))
                            self.populateChatUI()
                            self.sendButton.isEnabled = true
                        }
                    }
                }
            } catch {
                print("Error parsing DeepSeek response: \(error)")
            }
        }.resume()
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        handleSendMessage()
    }

    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        handleSendMessage()
        return true
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.chatScrollView.endEditing(true)
    }

    
    @objc func keyboardWillShow(notification: Notification) {
        self.askMealMentorIntroView.isHidden = true
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let height = keyboardRectangle.height
            let adjustedKeyboardHeight = height - view.safeAreaInsets.bottom + 10
            chatInputBarBottomConstraint.constant = adjustedKeyboardHeight
            sendButtonBottomConstraint.constant = adjustedKeyboardHeight
        }

    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if self.messages.count == 0 {
                self.askMealMentorIntroView.isHidden = false
            } else {
                self.askMealMentorIntroView.isHidden = true
            }

        chatInputBarBottomConstraint.constant = 10
        sendButtonBottomConstraint.constant = 10
    }
}
