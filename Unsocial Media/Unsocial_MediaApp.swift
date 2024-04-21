//
//  Unsocial_MediaApp.swift
//  Unsocial Media
//
//  Created by  Sadi on 21/3/24.
//

import SwiftUI
import Firebase
@main
struct Unsocial_MediaApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
