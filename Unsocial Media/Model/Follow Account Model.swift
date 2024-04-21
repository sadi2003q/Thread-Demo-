//
//  Follow Account Model.swift
//  Unsocial Media
//
//  Created by  Sadi on 3/4/24.
//

import Foundation
import SwiftfulFirestore


struct model_Follow: IdentifiableByString, Codable {
    let id, name, email: String
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case name = "name"
        case email = "email"
    }
}
