//
//  Authentication ViewModel.swift
//  Unsocial Media
//
//  Created by  Sadi on 27/3/24.
//

import Foundation
import Firebase
import FirebaseAuth
import Observation

@Observable
@MainActor
final class Authentication {
    
    static let shared = Authentication()
    
    func Identification() throws -> String {
        guard let user = Auth.auth().currentUser else { throw URLError(.badURL)}
        return user.email ?? "no email"
    }
    
    func Create_Account(with email: String, and password: String) async throws {
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
        } catch let error {
            throw error
        }
    }
    
    func Login_Account(with email: String, and password: String) async throws {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch let error {
            throw error
        }
    }

}
