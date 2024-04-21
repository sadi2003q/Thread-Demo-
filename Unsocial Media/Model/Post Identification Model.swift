//
//  Post Identification Model.swift
//  Unsocial Media
//
//  Created by  Sadi on 3/4/24.
//

import Foundation
import SwiftfulFirestore

struct model_PostIdentity : IdentifiableByString, Codable {
    let id, postAccount: String
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case postAccount = "postAccount"
    }
}
