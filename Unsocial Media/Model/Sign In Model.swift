//
//  Sign In Model.swift
//  Unsocial Media
//
//  Created by  Sadi on 27/3/24.
//

import Foundation
import SwiftfulFirestore
struct model_SignIn: IdentifiableByString, Codable, Hashable {
    
    let id, name, age, gender, email, password, url_profilePicture: String
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case age = "age"
        case gender = "gender"
        case email = "email"
        case password = "password"
        case url_profilePicture = "url_profilePicture"
    }
}
