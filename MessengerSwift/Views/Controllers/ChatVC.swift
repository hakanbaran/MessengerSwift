//
//  ChatVC.swift
//  MessengerSwift
//
//  Created by Hakan Baran on 11.07.2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView


struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "customc"
        }
    }
}

struct Sender: SenderType {
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}



class ChatVC: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formattre = DateFormatter()
        formattre.dateStyle = .medium
        formattre.timeStyle = .long
        formattre.locale = .current
        return formattre
    }()
    
    
    public var otherUserEmail = String()
    private var conversationID = String()
    public var isNewConversation = false
    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        
        return Sender(photoURL: "",
                      senderId: safeEmail ,
               displayName: "Me")
    }
    
    
    
    init(with email: String, id: String?) {
        
        self.otherUserEmail = email
        self.conversationID = id ?? ""
        
        super.init(nibName: nil, bundle: nil)
        

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messageInputBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        
        //        if let conversationID = conversationID {
        //            listenForMessages(id: conversationID, shouldScrollToBottom: true)
        //        }
        
        listenForMessages(id: conversationID, shouldScrollToBottom: true)
    }
    
//    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
//
//        print("ID Hatası alıyorum \(id)")
//
//        DatabaseManager.shared.getAllMessagesForConversation(with: id) { [weak self] result in
//
//
//            switch result {
//            case .success(let messages):
//                guard !messages.isEmpty else {
//                    return
//                }
//
//                self?.messages = messages
//                DispatchQueue.main.async {
//                    self?.messagesCollectionView.reloadDataAndKeepOffset()
//
//                    if shouldScrollToBottom {
//                        self?.messagesCollectionView.scrollToBottom()
//                    }
//                }
//            case .failure(let error):
//                print("Failed to get messages \(error)")
//            }
//        }
//    }
    
//    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
//        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
//            switch result {
//            case .success(let messages):
//                print("success in getting messages: \(messages)")
//                guard !messages.isEmpty else {
//                    print("messages are empty")
//                    return
//                }
//                self?.messages = messages
//
//                DispatchQueue.main.async {
//                    self?.messagesCollectionView.reloadDataAndKeepOffset()
//
//                    if shouldScrollToBottom {
//                        self?.messagesCollectionView.scrollToBottom()
//                    }
//                }
//            case .failure(let error):
//                print("failed to get messages: \(error)")
//            }
//        })
//    }
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                print("success in getting messages: \(messages)")
                guard !messages.isEmpty else {
                    print("messages are empty")
                    return
                }
                self?.messages = messages

                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()

                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
            case .failure(let error):
                print("failed to get messages: \(error)")
            }
        })
    }
    
    
}

extension ChatVC: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> MessageKit.SenderType {
        
        if let sender = selfSender {
            return sender
        }
        fatalError("Self sender is nil, email should be cached...")
        return Sender(photoURL: "", senderId: "12", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}

extension ChatVC: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
        let selfSender = self.selfSender,
        let messageID = createMessageID()  else {
            return
        }
        
        print("Sending: \(text)")
        
        let message = Message(sender: selfSender,
                              messageId: messageID,
                              sentDate: Date(),
                              kind: .text(text))
        
        // Send Message
        if isNewConversation {
            
            
            // Create convo in database
            
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message) { [weak self] success in
                if success {
                    print("Message Send")
                    self?.isNewConversation = false
                } else {
                    print("Failed to send...")
                }
            }
        } else {
            // Append to existing conversation data
            
           
            
            
            guard let conversationID = conversationID as? String, let name = self.title else {
                return
            }
            
            DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: otherUserEmail, name: name, newMessage: message) { success in
                if success {
                    print("Message Sent!!!")
                } else {
                    print("Failed to Send!!!")
                }
            }
        }
    }
    
    private func createMessageID() -> String? {
        
        // Date, OtherUserEmail, senderEmail, RandomInt
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        
        return newIdentifier
        
    }
    
}



