//
//  ChatMessage.swift
//  MealMentor
//
//  Created by Huyen Nguyen on 3/1/25.
//
import FirebaseFirestore

struct ChatMessage {
    let userId: String
    let message: String
    let sender: String
    let createdAt: Date
}
