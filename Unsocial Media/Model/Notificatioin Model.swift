//
//  Notificatioin Model.swift
//  Unsocial Media
//
//  Created by  Sadi on 10/4/24.
//

import Foundation
import SwiftfulFirestore
struct model_Notification: Codable, IdentifiableByString, Hashable {
    var id = UUID().uuidString
    let uid, name : String
    let custom : String
}
