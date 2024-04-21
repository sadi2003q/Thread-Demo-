//
//  Post Recieve Model.swift
//  Unsocial Media
//
//  Created by  Sadi on 1/4/24.
//

import Foundation
import SwiftfulFirestore
struct model_PostReceive :  Codable, IdentifiableByString {
    
    let id, postID: String
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case postID = "postID"
    }
}
