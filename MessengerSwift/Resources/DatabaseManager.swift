//
//  DatabaseManager.swift
//  MessengerSwift
//
//  Created by Hakan Baran on 7.07.2023.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String {
        
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    
    
}

// MARK: - Account Management

extension DatabaseManager {
    
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
//        safeEmail.replacingOccurrences(of: "@", with: "-")
        
        
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        }
        
    }
    
    
    
    
    
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("Failed to write to database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value) { snapshot in
                
                if var usersCollection = snapshot.value as? [[String: String]] {
                    // Append to user dictionary
                    
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                    
                } else {
                    // Create that array
                    
                    let newCollection : [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
            completion(true)
        })
    }
    
    public func getAllUsers(completion: @escaping (Result <[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
    
}



struct ChatAppUser {
    
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
//        safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
    
}

//MARK: - Sending Messages / Conversations

extension DatabaseManager {
    
    /*
        "dsdsdsfsfsfsfs" {
                    "messages" : [
     {
     
                            "id": String
                            "type": text, photo, video,
                            "content": String,
                            "date": Date(),
                            "sender_email": String,
                            "isRead": true/false
                        }
                    ]
                }
     
     conversation => [
        [
            "conversation_id": "dsdsdsfsfsfsfs"
            "other_user_email":
            "latest_message": => {
                "date": Date()
                "latest_message": "message"
                "is_read": true/false
                }
            ]
        ]
     
     */
    

    ///  Creates a new conversation with target user email and first message sent...
    
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User Not Found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatVC.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id": conversationID,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            let recipient_newConversationData: [String: Any] = [
                "id": conversationID,
                "other_user_email": safeEmail,
                "name": "Self",
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            // Update recipient conversation entry
            
//            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
//                if var conversations = snapshot.value as? [[String: Any]] {
//                    // Append
//                    conversations.append(recipient_newConversationData)
//                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversationID)
//                } else {
//                    // Create
//                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
//                }
//            }
            
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversatoins = snapshot.value as? [[String: Any]] {
                    // append
                    conversatoins.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversatoins)
                }
                else {
                    // create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            })
            
            
            // Update current user conversation entry
            if var conversation = userNode["conversations"] as? [[String: Any]] {
                
                // conversation array exists for current user
                // you should append
                conversation.append(newConversationData)
                userNode["conversations"] = conversation
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                }
            } else {
                // conversation array does NOT exist
                // create it
                userNode["conversations"] = [
                    newConversationData
                ]
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                }
            }
        }
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
//        {
//            "id": String,
//            "type": text, photo, video,
//            "content": String,
//            "date": Date(),
//            "sender_email": String,
//            "isRead": true/false,
//        }
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatVC.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name
        ]
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        print("Adding convo: \(conversationID)")
        database.child("\(conversationID)").setValue(value) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    
    
    /// Fetches and returns all conversations for the user with passed in email
    
    public func getAllConversations(for email: String, completion: @escaping(Result<[Conversation], Error>) -> Void) {

        database.child("\(email)/conversations").observe(.value) { snapshot  in

            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            let conversations: [Conversation] = value.compactMap { dictionary in
                guard let conversationID = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }

                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)

                return Conversation(id: conversationID, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)


            }

            completion(.success(conversations))
        }
    }
    
    /// Get all messages for a given conversations
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result <[Message], Error>) ->  Void) {

        database.child("\(id)/messages").observe(.value) { snapshot  in

            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            let messages : [Message] = value.compactMap { dictionary in
                guard let name = dictionary["name"] as? String,
//                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
//                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String,
                let date = dateString.toDate else {

                    print("DATE DÖNÜŞTÜRÜLEMEDİ!!!!!")

                    return Message(sender: Sender(photoURL: "", senderId: "", displayName: ""), messageId: "", sentDate: Date(), kind: .text(""))
             }
                
                

                print("DATE DÖNÜŞTÜÜÜÜ \(date)")
                
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                return Message(sender: sender, messageId: messageID, sentDate: date, kind: .text(content))

            }

            completion(.success(messages))
        }

    }
    
    
    /// Gets all mmessages for a given conversatino
//    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
//        database.child("\(id)/messages").observe(.value, with: { snapshot in
//            guard let value = snapshot.value as? [[String: Any]] else{
//                completion(.failure(DatabaseError.failedToFetch))
//                return
//            }
//
//            let messages: [Message] = value.compactMap({ dictionary in
//
//
//                guard let name = dictionary["name"] as? String,
////                    let isRead = dictionary["is_read"] as? Bool,
//                    let messageID = dictionary["id"] as? String,
//                    let content = dictionary["content"] as? String,
//                    let senderEmail = dictionary["sender_email"] as? String,
////                    let type = dictionary["type"] as? String,
//                    let dateString = dictionary["date"] as? String
//                else {
//                    return Message(sender: Sender(photoURL: "", senderId: "", displayName: ""), messageId: "", sentDate: Date(), kind: .text(""))
//                }
//
//                let sender = Sender(photoURL: "",
//                                    senderId: senderEmail,
//                                    displayName: name)
//
//                // 20 Jul 2023 21:37:37 GMT+3
//
//
//
//
//
//
////                func convertDateStringToDate(_ dateString: String) -> Date? {
////                    // DateFormatter nesnesi oluşturuyoruz
////                    let dateFormatter = DateFormatter()
////                    // Kaynak tarih formatını belirtiyoruz
////                    dateFormatter.dateFormat = "dd MMM yyyy HH:mm:ss z"
////                    // Locale'yi belirtiyoruz, GMT+3 kullanacağımızı belirtiyoruz
////                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
////                    // Zaman dilimiyle ilgili bilgiyi belirtiyoruz
////                    dateFormatter.timeZone = TimeZone(abbreviation: "GMT+3")
////
////                    // Tarih string'ini Date nesnesine dönüştürüyoruz
////                    if let date = dateFormatter.date(from: dateString) {
////                        return date
////                    } else {
////                        print("Geçersiz tarih formatı!")
////                        return nil
////                    }
////                }
////
////                // Örnek kullanım
//////                let dateString = "20 Jul 2023 21:37:37 GMT+3"
////                if let date = convertDateStringToDate(dateString) {
////                    let dateFormatter = DateFormatter()
////                    // Hedef tarih formatını belirtiyoruz (isteğe bağlı)
////                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
////                    let formattedDate = dateFormatter.string(from: date)
////                    print("SONUÇLAAAARRRR: \(formattedDate)") // Örnek çıktı: "2023-07-20 21:37:37"
////                }
//
//
//
//                let date = ChatVC.dateFormatter.date(from: dateString)
//
//                print("HAKANYUM    \(dateString)")
//                print("BARANYUM     \(date)")
//
//                return Message(sender: sender,
//                               messageId: messageID,
//                               sentDate: date ?? Date(),
//                               kind: .text(content))
//            })
//
//            completion(.success(messages))
//        })
//    }
    
    /// Sends a message with target conversation and message
    
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {
        
    }
    
    
    
    
}

