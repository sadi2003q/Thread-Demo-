//
//  Storage.swift
//  Unsocial Media
//
//  Created by  Sadi on 28/3/24.
//

import Foundation
import FirebaseStorage
import Observation
import UIKit
import FirebaseAuth

@MainActor
@Observable
final class Store {
    
    static let shared = Store()
    
    private let store = Storage.storage().reference()
    
    private func uid() throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        return user.uid
        
    }
    
    
    private func reference(userId: String) -> StorageReference {
        store.child(userId)
    }
    
    private func SaveImage(data: Data, uid: String) async throws -> (path: String, name: String) {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await reference(userId: uid).child(path).putDataAsync(data, metadata: meta)
        
        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else { throw URLError(.badURL)}
        
        print("name: \(returnedName)")
        print("Path: \(returnedPath)")
        
        
        return (returnedPath, returnedName)
    }
//    @discardableResult
    func Upload(the image: UIImage) async throws -> (path: String, name: String) {
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            throw URLError(.badURL)
        }
        let uid = try uid()
        return try await SaveImage(data: data, uid: uid)
    }
    
    func Upload_getURL(the image: UIImage) async throws -> URL {
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            throw URLError(.badURL)
        }
        let uid = try uid()
        let (_, name) = try await SaveImage(data: data, uid: uid)
        return try await getURL(from: name, uid: uid)
    }
    
    
    func download(from name: String, of uid: String) async throws -> UIImage {
        let data = try await reference(userId: uid).child(name).data(maxSize: 3*1024*1024)
        
        guard let image = UIImage(data: data) else {throw URLError(.badURL)}
        return image
    }
//    @discardableResult
    func getURL(from path: String, uid: String) async throws -> URL {
        do {
            let url = try await reference(userId: uid).child(path).downloadURL()
            print("URL : \(url.absoluteString)")
            return url
        } catch let error { throw error }
    }
}
