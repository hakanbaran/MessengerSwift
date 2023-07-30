//
//  StorageMnager.swift
//  MessengerSwift
//
//  Created by Hakan Baran on 13.07.2023.
//

import Foundation
import FirebaseStorage

public enum StorageErrors: Error {
    case failedToUpload
    case failedToGetDownloadUrl
}

final class StorageManager {
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    /*
     /images/afraz9-gmail-com_profile_picture.png
     */
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    // Uploads picture to firebase storage and returns completion with url string to download
    
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        
        storage.child("images/\(fileName)").putData(data, metadata: nil) { metadata, error in
            guard error == nil else {
                // failed
                print("Failed to Upload data to Firebase For picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url returned: \(urlString)")
                completion(.success(urlString))
            }
        }
        
    }
    
    
    /// Upload image that will be sent in a conversation Message
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        
        storage.child("message_images/\(fileName)").putData(data, metadata: nil) { [weak self ] metadata, error in
            guard error == nil else {
                // failed
                print("Failed to Upload data to Firebase For picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url returned: \(urlString)")
                completion(.success(urlString))
            }
        }
        
    }
    
    
    /// Upload video that will be sent in a conversation Message
    public func uploadMessageVideo(with fileURL: URL, fileName: String, completion: @escaping UploadPictureCompletion) {
        
        
        
        storage.child("message_videos/\(fileName)").putFile(from: fileURL, metadata: nil) { [weak self] metadata, error in
            
            print("HAKANYUM: \(fileName)")
            
            print("BARANYUM \(fileURL)")
            
            guard error == nil else {
                // failed
                print("Failed to Upload video file to Firebase For picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_videos/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url returned: \(urlString)")
                completion(.success(urlString))
            }
        }
        
    }
    
    
    
    
    public func downloadURL(for path: String, completion: @escaping(Result <URL, Error>) -> Void) {
        let referance = storage.child(path)
        referance.downloadURL { url, error in
            guard let url = url , error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        }
    }
    
}
