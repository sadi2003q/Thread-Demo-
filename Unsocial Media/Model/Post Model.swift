//
//  Post Model.swift
//  Unsocial Media
//
//  Created by  Sadi on 31/3/24.
//

import Foundation
import SwiftfulFirestore
struct model_Post : IdentifiableByString, Codable, Hashable {
    let id, signature, name, title, url_Image: String
    let date: Date
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case signature = "signature"
        case name = "name"
        case title = "title"
        case url_Image = "url_Image"
        case date = "date"
    }
}
struct commentModel: IdentifiableByString, Codable, Hashable {
    var id, signature, name, comment: String
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case name = "name"
        case signature = "signature"
        case comment = "comment"
    }
}

struct reactModel: IdentifiableByString, Codable, Hashable {
    var id, name: String
    enum CodingKeys : String, CodingKey {
        case id = "id"
        
        case name = "name"

    }
}
