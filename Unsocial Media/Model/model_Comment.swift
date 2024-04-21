//
//  model_Comment.swift
//  Unsocial Media
//
//  Created by  Sadi on 6/4/24.
//

import Foundation
import SwiftfulFirestore

struct model_comment: IdentifiableByString, Hashable, Codable {
    let id, userID, text: String
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case userID = "ID"
        case text = "text"
    }
}
