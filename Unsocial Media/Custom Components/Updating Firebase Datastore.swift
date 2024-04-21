//
//  Updating Firebase Datastore.swift
//  Unsocial Media
//
//  Created by  Sadi on 7/4/24.
//

import Foundation
/*
 private func userIsReacted(id: String, value: [String]) {
     Task {
         do {
             try await DataBase.shared.collection_PublicPost.document(id).updateData([
                 model_Post.CodingKeys.reactAccount.rawValue : value
             ])
         } catch let error {
             print("error : \(error.localizedDescription)")
         }
     }
 }
 Task {
     var updatedModel = model
     if updatedModel.reactAccount.contains(id) {
         let index = updatedModel.reactAccount.firstIndex{$0 == id}
         updatedModel.reactAccount.remove(at: index ?? 0)
     } else {
         updatedModel.reactAccount.append(id)
     }
     
     if let index = Post.firstIndex(of: model) {
         Post[index] = updatedModel
     }

     userIsReacted(id: model.id, value: updatedModel.reactAccount)
 }
 
 
 
 private func addComment(id: String, value: [[String: String]]) {
     Task {
         do {
             try await DataBase.shared.collection_PublicPost.document(id).updateData([
                 model_Post.CodingKeys.comment.rawValue : value
             ])
         } catch let error {
             print("error : \(error.localizedDescription)")
         }
     }
 }
 Task {
     var updatedModel = model
     updatedModel.comment.append([id : "i am working"])
     if let index = Post.firstIndex(of: model) {
         Post[index] = updatedModel
     }
     
     addComment(id: model.id, value: updatedModel.comment)
     
 }
 
 
 
 
 
 
 
 
 Task {
     var updatedModel = model
     if updatedModel.reactAccount.contains(id) {
         let index = updatedModel.reactAccount.firstIndex{$0 == id}
         updatedModel.reactAccount.remove(at: index ?? 0)
     } else {
         updatedModel.reactAccount.append(id)
     }
     
     if let index = Post.firstIndex(of: model) {
         Post[index] = updatedModel
     }
     
     userIsReacted(id: model.id, value: updatedModel.reactAccount)
 }
 
 
 Task {
     var updatedModel = model
     updatedModel.comment.append([id : commentText])
     if let index = Post.firstIndex(of: model) {
         Post[index] = updatedModel
     }
     
     addComment(id: model.id, value: updatedModel.comment)
     self.commentText = ""
 }
 
 
 
 
 
 
 */
