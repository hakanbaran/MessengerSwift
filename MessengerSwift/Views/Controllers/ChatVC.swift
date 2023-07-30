//
//  ChatVC.swift
//  MessengerSwift
//
//  Created by Hakan Baran on 11.07.2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit


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

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
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
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        setupInputButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        
        listenForMessages(id: conversationID, shouldScrollToBottom: true)
    }
    
    
    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: true)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        
        
        let scale: CGFloat = 1.3

        // Ölçekleme işlemini gerçekleştirin
        button.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        
        
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: true)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: true)
    }
    
    private func presentInputActionSheet() {
        
        
        
        let actionSheet = UIAlertController(title: "Attach Media", message: "What would you like to attachhe?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputActionSheet()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: {  [weak self] _ in
            
            self?.presentVideoInputActionSheet()
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: {  _ in
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
        
    }
    
    private func presentPhotoInputActionSheet() {
        
        let actionSheet = UIAlertController(title: "Attach Photo", message: "Where would you lile to attach a photo from?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {  [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
            
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:  nil))
        
        present(actionSheet, animated: true)
        
    }
    
    
    private func presentVideoInputActionSheet() {
        
        let actionSheet = UIAlertController(title: "Attach Video", message: "Where would you lile to attach a video from?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: {  [weak self] _ in
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            self?.present(picker, animated: true)
            
            
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:  nil))
        
        present(actionSheet, animated: true)
        
    }
    
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


extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let messageID = createMessageID(),
        let conversationID = conversationID as? String,
        let name = self.title,
        let selfSender = selfSender else {
            return
        }
        
        if let image = info[.editedImage] as? UIImage, let imageData = image.pngData() {
            
            let fileName = "photo_message_" + messageID.replacingOccurrences(of: " ", with: "-") + ".png"
            
            
            // Upload Image
            StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName) { [weak self] result in
                
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                case .success(let urlString):
                    // Ready to send message
                    
                    print("Uploaded Message Photo: \(urlString)")
                    
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else {
                        return
                    }
                    
                    
                    let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                    
                    
                    let message = Message(sender: selfSender,
                                          messageId: messageID,
                                          sentDate: Date(),
                                          kind: .photo(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: strongSelf.otherUserEmail, name: name , newMessage: message) { success in
                        
                        if success {
                            print("Sent Photo Message")
                        } else {
                            print("Failed to send photo message")
                        }
                        
                    }
                case .failure(let error):
                    print("Message photo upload error: \(error)")
                }
            }
            
        }
        else if let videoURL = info[.mediaURL] as? URL {
            
            print("HAKANBARAN \(videoURL) 1111111")
            
            let fileName = "photo_message_" + messageID.replacingOccurrences(of: " ", with: "-") + ".mov"
            
            // Upload Video
            
            
            
            StorageManager.shared.uploadMessageVideo(with: videoURL, fileName: fileName) { [weak self] result in
                
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                case .success(let urlString):
                    // Ready to send message
                    
                    print("Uploaded Message Video: \(urlString)")
                    
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else {
                        return
                    }
                    
                    
                    let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                    
                    
                    let message = Message(sender: selfSender,
                                          messageId: messageID,
                                          sentDate: Date(),
                                          kind: .video(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: strongSelf.otherUserEmail, name: name , newMessage: message) { success in

                        if success {
                            print("Sent Photo Message")
                        } else {
                            print("Failed to send photo message")
                        }
                        
                    }
                case .failure(let error):
                    print("Message photo upload error: \(error)")
                }
            }
        }
        
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
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind {
        case .photo(let media):
            guard let imageURL = media.url else {
                return
            }
            imageView.sd_setImage(with: imageURL)
        default:
            break
        }
    }
}


extension ChatVC: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }

        guard let message = messages[indexPath.section] as? Message else {
            return
        }

        switch message.kind {
        case .photo(let media):
            guard let imageURL = media.url else {
                return
            }
            let vc = PhotoViewerVC(with: imageURL)
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .video(let media):
            guard let videoURL = media.url else {
                return
            }
            
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoURL)
            present(vc, animated: true)
            
        default:
            break
        }
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



