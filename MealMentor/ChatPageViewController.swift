//
//  ChatPageViewController.swift
//  MealMentor
//
//  Created by Huyen Nguyen on 2/24/25.
//

import UIKit
import FirebaseFirestore

class ChatPageViewController: UIViewController {

    @IBOutlet weak var askMealMentorIntroView: UIView!
    @IBOutlet weak var chatInputBar: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var chatStackView: UIStackView!
    var chatScrollView: UIScrollView!

    let db = Firestore.firestore()
    // temporary hard-coded user id
    let currentUserId = "2fUZi54QesUbquSJAp9M"
    var messages: [ChatMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        askMealMentorIntroView.layer.cornerRadius = 10
        askMealMentorIntroView.clipsToBounds = true
        sendButton.tintColor = UIColor.systemIndigo
        chatInputBar.layer.cornerRadius = 90
        
        chatScrollView = UIScrollView()
        chatScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chatScrollView)
        NSLayoutConstraint.activate([
            chatScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 87),
            chatScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            chatScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            chatScrollView.bottomAnchor.constraint(equalTo: chatInputBar.topAnchor, constant: -30)
        ])
        
        chatStackView = UIStackView()
        chatStackView.axis = .vertical
        chatStackView.alignment = .fill
        chatStackView.distribution = .fill
        chatStackView.spacing = 8
        chatStackView.translatesAutoresizingMaskIntoConstraints = false
        chatScrollView.addSubview(chatStackView)
        NSLayoutConstraint.activate([
            chatStackView.topAnchor.constraint(equalTo: chatScrollView.topAnchor),
            chatStackView.leadingAnchor.constraint(equalTo: chatScrollView.leadingAnchor),
            chatStackView.trailingAnchor.constraint(equalTo: chatScrollView.trailingAnchor),
            chatStackView.bottomAnchor.constraint(equalTo: chatScrollView.bottomAnchor),
            chatStackView.widthAnchor.constraint(equalTo: chatScrollView.widthAnchor)
        ])
        
        setupKeyboardNotifications()
        fetchChats()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        chatInputBar.layer.cornerRadius = chatInputBar.frame.height / 2
        chatInputBar.clipsToBounds = true
    }
    
    func fetchChats() {
        let oneWeekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        let timestamp = Timestamp(date: oneWeekAgo)
        
        db.collection("chats")
            .whereField("userId", isEqualTo: currentUserId)
            .whereField("createdAt", isGreaterThan: timestamp)
            .order(by: "createdAt", descending: false)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching chats: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.showAskMealMentorIntroView()
                    return
                }
                
                if documents.isEmpty {
                    self.showAskMealMentorIntroView()
                } else {
                    self.askMealMentorIntroView.isHidden = true
                    self.messages = documents.compactMap { (doc) -> ChatMessage? in
                        let data = doc.data()
                        guard let message = data["message"] as? String,
                              let sender = data["sender"] as? String,
                              let userId = data["userId"] as? String,
                              let createdAt = data["createdAt"] as? Timestamp else {
                            return nil
                        }
                        return ChatMessage(userId: userId, message: message, sender: sender, createdAt: createdAt.dateValue())
                    }
                    self.populateChatUI()
                }
            }
    }
    
    func showAskMealMentorIntroView() {
        self.askMealMentorIntroView.isHidden = false
    }
    
    func populateChatUI() {
        // Clear previous messages
        chatStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for chat in messages {
            // Create the horizontal container for message alignment
            let messageContainer = UIStackView()
            messageContainer.axis = .horizontal
            messageContainer.alignment = .fill
            messageContainer.spacing = 8
            messageContainer.translatesAutoresizingMaskIntoConstraints = false
            
            // Configure bubble label
            let bubbleLabel = PaddingLabel()
            bubbleLabel.text = chat.message
            bubbleLabel.numberOfLines = 0
            bubbleLabel.layer.cornerRadius = 10
            bubbleLabel.clipsToBounds = true
            bubbleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            if chat.sender == "user" {
                bubbleLabel.backgroundColor = UIColor.lightGray
                bubbleLabel.textAlignment = .right
            } else if chat.sender == "ai" {
                bubbleLabel.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.3)
                bubbleLabel.textAlignment = .left
            } else {
                bubbleLabel.backgroundColor = UIColor.red.withAlphaComponent(0.3)
                bubbleLabel.textAlignment = .center
            }
            
            // Add bubble label to the container and set the maximum width relative to the container
            if chat.sender == "user" {
                let spacer = UIView()
                spacer.translatesAutoresizingMaskIntoConstraints = false
                messageContainer.addArrangedSubview(spacer)
                messageContainer.addArrangedSubview(bubbleLabel)
            } else {
                messageContainer.addArrangedSubview(bubbleLabel)
                let spacer = UIView()
                spacer.translatesAutoresizingMaskIntoConstraints = false
                messageContainer.addArrangedSubview(spacer)
            }
            
            bubbleLabel.widthAnchor.constraint(lessThanOrEqualTo: messageContainer.widthAnchor, multiplier: 0.7).isActive = true

            chatStackView.addArrangedSubview(messageContainer)
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard let text = chatInputBar.text, !text.isEmpty else { return }
        
        // Create a new document in Firestore with the required fields.
        let newChat: [String: Any] = [
            "message": text,
            "userId": currentUserId,
            "createdAt": Timestamp(date: Date()),
            "sender": "user"
        ]
        
        db.collection("chats").addDocument(data: newChat) { error in
            if let error = error {
                print("Error sending message: \(error)")
                return
            }
            // Clear the input field.
            self.chatInputBar.text = ""
            // Append the new message to the local array and update the UI.
            self.messages.append(ChatMessage(userId: self.currentUserId, message: text, sender: "user", createdAt: Date()))
            self.populateChatUI()
        }
    }
    
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        // Update constraints or view frame so the chat input bar remains visible.
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        // Revert any changes made when the keyboard appeared.
    }
}

class PaddingLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }
}
