//
//  Test Downloading Post.swift
//  Unsocial Media
//
//  Created by  Sadi on 20/4/24.
//

import SwiftUI
import Observation
import SwiftfulFirestore
import FirebaseFirestore
import FirebaseFirestoreSwift

private struct model : IdentifiableByString, Hashable, Codable {
    var id = UUID().uuidString
    var v: Int

}


// working with this test file to make things work
// working with this another file to help myself learning this things
// nothing
// another code is written here

private class StorageFile {
    
    static let shared = StorageFile()
    
    let collection = Firestore.firestore().collection("document")
    
    func add(m: model) async throws {
        do {
            try collection.addDocument(from: m)
        } catch let error { throw error }
    }
    
    func download() async throws -> [model] {
        do {
            return try await collection.limit(to: 10).getDocuments(as: model.self)
        } catch let error { throw error }
    }
    
    
    
    
    
}






struct Test_Downloading_Post: View {
    
    @State private var m : [model] = []
    
    
    var body: some View {
        VStack {
            _button_Upload
            _button_download
            
            _m_info
        }
    }
    
    
    private var _m_info: some View {
        ScrollView {
            List {
                List(m) { item in
                           Text("Index: \(item.v)")
                               .padding()
                }
                .foregroundStyle(Color.blue)
            }
            .frame(maxHeight: .infinity)
        }
        
        
    }
    
    
    private var _button_download: some View {
        Button("Downlaod") {
            Task {
                try await downloadDocument()
            }
        }
        .buttonStyle(BorderedButtonStyle())
    }
    
    private var _button_Upload: some View {
        Button("Upload Button") {
            Task {
                try await uploadDocument()
            }
            
        }
        .buttonStyle(BorderedButtonStyle())
    }
    
    
    private func uploadDocument() async throws {
        for i in 1..<81 {
            do {
                try await StorageFile.shared.add(m: model(v: i))
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    
    private func downloadDocument() async throws {
        do {
            self.m = try await StorageFile.shared.download()
            print("download complete : \(m.count)")
        } catch let error { print(error.localizedDescription) }
    }
    
    
}

#Preview {
    Test_Downloading_Post()
}
