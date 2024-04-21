//
//  Public Information Model.swift
//  Unsocial Media
//
//  Created by  Sadi on 31/3/24.
//

import Foundation
import SwiftfulFirestore

struct model_PublicInformation : IdentifiableByString, Codable, Hashable {
    let id, name, email, url_Image: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case email = "email"
        case url_Image = "url_Image"
        
    }
    
}
