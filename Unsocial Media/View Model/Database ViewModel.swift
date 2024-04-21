//
//  Sign in ViewModel.swift
//  Unsocial Media
//
//  Created by  Sadi on 27/3/24.
//

import Foundation
import Firebase
import FirebaseAuth
import SwiftfulFirestore
import FirebaseFirestore
import FirebaseFirestoreSwift
import Observation

@Observable

//MARK: PERSONAL INFORMATION DATABSE
final class DataBase {
    
    static let shared = DataBase()
    
    //MARK: PERSONAL INFORMATION DATEBASE
    private let collection_PersonalInformation = Firestore.firestore().collection("Personal Information")
    
    //MARK: PUBLIC DATABASE
    let collection_PublicInformation = Firestore.firestore().collection("Public Information")
    
    func collection_MyPost(id: String) -> CollectionReference {
        collection_PersonalInformation.document(id).collection("My Post")
    }
    
    //MARK: PERSONAL DATABASE
    func collection_PersonalFollowing(id: String) -> CollectionReference {
        collection_PersonalInformation.document(id).collection("Following")
    }
    
    func collection_PersonalFollower(id: String) -> CollectionReference {
        collection_PersonalInformation.document(id).collection("Follower")
    }
    
    func collection_FriendsPost(id : String) -> CollectionReference {
        collection_PersonalInformation.document(id).collection("Post")
    }
    
    func collection_PostReact(post id: String) -> CollectionReference {
        collection_PublicPost.document(id).collection("React's")
    }
    
    func collection_PostComments(post id: String) -> CollectionReference {
        collection_PublicPost.document(id).collection("comment's")
    }
    
    func collection_Notification(id: String) -> CollectionReference {
        collection_PersonalInformation.document(id).collection("Notification")
    }
    
    
    
    //MARK: POST DATABASE
    let collection_PublicPost = Firestore.firestore().collection("Public Post")
    
    
    
    func Identification() async throws -> String {
        guard let user = Auth.auth().currentUser  else {
            throw URLError(.badURL)
        }
        return user.email ?? "no email"
    }
    
    func Upload_PersonalInformation(users information: model_SignIn) async throws {
        Task {
            do {
                try await collection_PublicInformation.setDocument(document: model_PublicInformation(id: information.id, name: information.name, email: information.email, url_Image: information.url_profilePicture))
                try await collection_PersonalInformation.setDocument(document: information)
            } catch let error {
                throw error
            }
        }
    }
    
    func Download_PersonalInformation() async throws -> [model_SignIn] {
        do {
            let uid =  try await Identification() //change
            return try await collection_PersonalInformation.whereField(model_SignIn.CodingKeys.id.rawValue, isEqualTo: uid).getDocuments(as: model_SignIn.self)
        } catch let error {
            throw error
        }
    }
    
    
    
    
    func downloadSpecific(id: String) async throws -> [model_SignIn] {
        do {
            return try await collection_PersonalInformation.whereField(model_PublicInformation.CodingKeys.id.rawValue, isEqualTo: id).getDocuments(as: model_SignIn.self)
        } catch let error {
            throw error
        }
    }
    
    
    func Update_ProfilePicture_information(imageURL: String) async throws {
        do {
            let uid = try await Identification()
            let documentRef = collection_PersonalInformation.document(uid)
            
            do {
                try await documentRef.updateData([model_SignIn.CodingKeys.url_profilePicture.rawValue : imageURL])
                print("Document successfully updated with new 'number' value")
            } catch {
                // Handle error if update fails
                print("Error updating 'number' field: \(error)")
                throw error
            }
        } catch {
            // Handle error if identification fails
            print("Error identifying user: \(error)")
            throw error
        }
    }
    
    
    
    func Upload_Post(model: model_Post) async throws {
        Task {
            do {
                let id = try await Authentication.shared.Identification()
                try await collection_FriendsPost(id: id).setDocument(document: model_PostIdentity(id: model.id, postAccount: model.signature))
                try await collection_MyPost(id: id).setDocument(document: model_PostIdentity(id: model.id, postAccount: model.signature))
                try await collection_PublicPost.setDocument(document: model)
                
            } catch let error {
                throw error
            }
        }
    }
    
    func Follow(model: model_PublicInformation) async throws {
        Task {
            do {
                let id = try await Identification()
                let user = try await collection_PublicInformation.whereField(model_PublicInformation.CodingKeys.id.rawValue, isEqualTo: id).getDocuments(as: model_PublicInformation.self)
                try await collection_PersonalFollower(id: model.id).setDocument(document: user[0])
                try await collection_PersonalFollowing(id: id).setDocument(document: model)
            } catch let error {
                throw error
            }
        }
    }
    
    
    func UpPost(id : String, model : model_PostIdentity) async throws {
        do {
            try await collection_FriendsPost(id: id).setDocument(document: model)
        } catch let error {
            throw error
        }
    }
    
    func DownloadPost() async throws -> [model_PostIdentity] {
        do {
            let id = try await Identification()
            return try await collection_FriendsPost(id: id).getAllDocuments()
            
        } catch let error {
            throw error
        }

    }
    
    //MARK: REACT AND COMMENT
    func addComments(id: String, model : commentModel) async throws {
        do {
            try await collection_PostComments(post: id).setDocument(document: model)
        } catch let error {
            throw error
        }
    }
    
    func addReact(id: String, model : reactModel) async throws {
        do {
            try await collection_PostReact(post: id).setDocument(document: model)
        } catch let error {
            throw error
        }
    }
    
    func removeReact(post id: String, user uid: String) async throws {
        do {
            try await collection_PostReact(post: id).deleteDocument(id: uid)
        } catch let error { throw error }
    }
    

    //MARK: NOTIFICATION
    ///to whome i am senting the notification
    func sentNotification(id: String, custom : notification, model : model_SignIn) async throws {

            do {
                try await collection_Notification(id: id).setDocument(document: model_Notification(uid: model.id, name: model.name, custom: custom.rawValue))
            } catch let error {
                throw error
            }

        
    }
    
}


enum notification: String {
    case like = "Like your post on your post"
    case comment = "make a comment on your post"
    case follow = "start's following you"
}








extension Query {
    
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        try await getDocumentsWithSnapshot(as: type).products
    }
    
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (products: [T], lastDocument: DocumentSnapshot?) where T : Decodable {
        let snapshot = try await self.getDocuments()
        
        let products = try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
        
        return (products, snapshot.documents.last)
    }
    
    func startOptionally(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        guard let lastDocument else { return self }
        return self.start(afterDocument: lastDocument)
    }
    
    func aggregateCount() async throws -> Int {
        let snapshot = try await self.count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }
    
    
    
}
