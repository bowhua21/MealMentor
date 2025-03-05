//
//  ChatPageViewController.swift
//  MealMentor
//
//  Created by Huyen Nguyen on 2/24/25.
//

import UIKit
import FirebaseFirestore

class ChatPageViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var askMealMentorIntroView: UIView!
    @IBOutlet weak var chatInputBar: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatInputBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButtonBottomConstraint: NSLayoutConstraint!
    
    var chatStackView: UIStackView!
    var chatScrollView: UIScrollView!

    let db = Firestore.firestore()
    // temporary hard-coded user id
    let currentUserId = "2fUZi54QesUbquSJAp9M"
    var messages: [ChatMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatInputBar.delegate = self
        
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
            chatScrollView.bottomAnchor.constraint(equalTo: chatInputBar.topAnchor, constant: -10)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sendButton.tintColor = UIColor.systemIndigo

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sendButton.tintColor = UIColor.systemIndigo

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
        chatStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for chat in messages {
            let messageContainer = UIStackView()
            messageContainer.axis = .horizontal
            messageContainer.alignment = .fill
            messageContainer.spacing = 8
            messageContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let bubbleLabel = ChatBubble()
            bubbleLabel.text = chat.message
            bubbleLabel.numberOfLines = 0
            bubbleLabel.layer.cornerRadius = 10
            bubbleLabel.clipsToBounds = true
            bubbleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            if chat.sender == "user" {
                bubbleLabel.backgroundColor = UIColor.systemGray.withAlphaComponent(0.3)
                bubbleLabel.textAlignment = .right
            } else if chat.sender == "ai" {
                bubbleLabel.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.3)
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
            
            bubbleLabel.widthAnchor.constraint(lessThanOrEqualTo: messageContainer.widthAnchor, multiplier: 0.7).isActive = true

            chatStackView.addArrangedSubview(messageContainer)
        }
    }
    
    func handleSendMessage() {
        guard let text = chatInputBar.text, !text.isEmpty else { return }
        
        let newChat = [
            "message": text,
            "userId": currentUserId,
            "createdAt": Timestamp(date: Date()),
            "sender": "user"
        ] as [String : Any]
        
        db.collection("chats").addDocument(data: newChat) { error in
            if let error = error {
                print("Error: \(error)")
                return
            }

            self.chatInputBar.text = ""
            self.messages.append(ChatMessage(userId: self.currentUserId, message: text, sender: "user", createdAt: Date()))
            self.populateChatUI()
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        handleSendMessage()
    }
    
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
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
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        let adjustedKeyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom + 10

        chatInputBarBottomConstraint.constant = adjustedKeyboardHeight
        sendButtonBottomConstraint.constant = adjustedKeyboardHeight
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        chatInputBarBottomConstraint.constant = 10
        sendButtonBottomConstraint.constant = 10
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
}
