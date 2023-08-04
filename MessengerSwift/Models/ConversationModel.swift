//
//  ConversationModel.swift
//  MessengerSwift
//
//  Created by Hakan Baran on 4.08.2023.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
