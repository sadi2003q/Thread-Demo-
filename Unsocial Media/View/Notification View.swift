//
//  Notification View.swift
//  Unsocial Media
//
//  Created by  Sadi on 10/4/24.
//

import SwiftUI

struct Notification_View: View {
    
    @State private var name : [String] = ["adnan", "abdullah", "sadi"]
    
    @State private var model : [model_Notification] = []
    
    @State private var id: String = ""
    
    var body: some View {
        ZStack {
            Color.loginBackground.ignoresSafeArea()
            _notificationView
            
        }
        .onAppear {
            Task {
                try await Identification()
                try await DownloadAllNotification()
            }
        }
        .foregroundStyle(Color.white)
    }
    
    private var _notificationView: some View {
        VStack {
            HStack {
                Text("Notification")
                    .font(.largeTitle)
                    .foregroundStyle(Color.white)
                Spacer()
            }
            .padding(.horizontal)
            ScrollView {
                ForEach(model, id: \.self) { item in
                    VStack {
                        HStack {
                            Circle()
                                .frame(width: 50, height: 50)
                                .overlay {
                                    
                                    if item.custom == notification.like.rawValue {
                                        Image(systemName: "heart.circle")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(Color.black)
                                    } else if item.custom == notification.comment.rawValue {
                                        Image(systemName: "ellipsis.bubble")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(Color.black)
                                    } else if item.custom == notification.follow.rawValue {
                                        Image(systemName: "figure.stand.line.dotted.figure.stand")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(Color.black)
                                    }
                                    
                                    
                                }
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .bold()
                                Text("has " + item.custom)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 300, height: 4)
                            .padding(.vertical)
                    }
                    
                }
                
            }
        }
        .padding(.top, 30)
        
    }
    
    private func DownloadAllNotification() async throws {
        let collection = DataBase.shared.collection_Notification(id: id)
        for try await not : [model_Notification] in collection.streamAllDocuments(onListenerConfigured: { _ in }) {
            self.model = not
        }
    }
    
    private func Identification() async throws {
        do {
            self.id = try await DataBase.shared.Identification()
        } catch let error { print(error.localizedDescription) }
    }
    
    
    
}

#Preview {
    Notification_View()
}
