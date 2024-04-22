//
//  Test.swift
//  Unsocial Media
//
//  Created by  Sadi on 22/4/24.
//

import SwiftUI
import SwiftfulFirestore
import FirebaseFirestore
import FirebaseFirestoreSwift

struct testModel : IdentifiableByString, Codable {
    var id = UUID().uuidString
    let index : Int
}

private class ViewModel {
    static let shared = ViewModel()
    
    let collection = Firestore.firestore().collection("document")
    
    func download(batchSize: Int, startAfterDocument: DocumentSnapshot? = nil) async throws -> ([testModel], DocumentSnapshot?) {
        var query = collection
            .limit(to: batchSize)
        
        if let startAfterDocument = startAfterDocument {
            query = query.start(afterDocument: startAfterDocument)
        }

        let querySnapshot = try await query.getDocuments()

        // Convert query snapshot to array of testModel
        let documents = querySnapshot.documents.compactMap { queryDocumentSnapshot -> testModel? in
            // Attempt to decode each document to testModel
            do {
                return try queryDocumentSnapshot.data(as: testModel.self)
            } catch {
                print("Error decoding document: \(error)")
                return nil
            }
        }

        // Get the last document snapshot from the query snapshot
        let lastDocumentSnapshot = querySnapshot.documents.last

        return (documents, lastDocumentSnapshot)
    }
}



struct Test: View {
    
    @State private var lastDocumentSnapshot: DocumentSnapshot? = nil
    @State private var test : [testModel] = []
    @State private var model : [testModel] = []
    
    
    
    var body: some View {
        ScrollView {
            _button_download
            ForEach(model) { item in
                Text("\(item.index)")
            }
        }
    }
    
    private var _button_download: some View {
        Button("download from Store") {
            Task {
                try await download()
            }
        }
    }
    
    
    private func download() async throws {
        do {
            if let lastDocumentSnapshot {
                (self.test, self.lastDocumentSnapshot) = try await ViewModel.shared.download(batchSize: 10, startAfterDocument: lastDocumentSnapshot)
            } else {
                (self.model, self.lastDocumentSnapshot) = try await ViewModel.shared.download(batchSize: 10)
            }
            
            filterAdd(m: test)
            
            print("download complete : \(model.count)")
        } catch let error { print(error.localizedDescription) }
    }
    
    
    private func filterAdd(m : [testModel]) {
        for item in m {
            if !model.contains(where: { $0.id == item.id }) {
                self.model.append(item)
            }
        }
    }
    
}

#Preview {
    Test()
}
