//
//  Alternative NewsFeed View.swift
//  Unsocial Media
//
//  Created by  Sadi on 15/4/24.
//

import SwiftUI
import LRUCache
import SwiftfulUI
import SwiftfulFirestore

private struct postShowModel: Identifiable, Hashable {
    let id = UUID().uuidString
    let name: String
    let imageURL: String
    let post: model_Post
}


struct Alternative_NewsFeed_View: View {
    
    @State private var width : CGFloat = { UIScreen.main.bounds.width }()
    @State private var height : CGFloat = { UIScreen.main.bounds.height }()
    
    @State private var id: String = ""
    @State private var postCache = LRUCache<String, model_Post>()
    @State private var postCatchModel = LRUCache<String, postShowModel>()
    @State private var allKeys: [String] = []
    
    @State private var x : CGFloat = 0.0
    @State private var y : CGFloat = 0.0
    
    
    @AppStorage ("storage") private var isReloading : Bool = false
    
    @State private var nextPage: Bool = false
    
    init() {
        
        self.isReloading = false
    }
    
    var body: some View {
        
            ScrollView {
                Image(.threadsLogoPNG)
                    .resizable()
                    .frame(width: 60, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .onTapGesture {
                        self.nextPage.toggle()
                    }
                postView
        }
        .nav()
        .onAppear {
            
            Task {
                try await Identification()
                if isReloading == false {
                    try await downloadPost()
                    self.isReloading = true
                }
                
                
                
            }
            Position(position: "inside appear function")
        }
    }
    
    private var postView: some View {
        
        ForEach(allKeys, id: \.self) { key in
            if let Post = postCatchModel.value(forKey: key) {
                HStack(alignment : .top) {
                    Circle()
                        .frame(width: 50, height: 50)
                        .overlay {
                                
                                AsyncImage(url: URL(string: Post.imageURL)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                } placeholder: {
                                    ProgressView()
                                }

                                                        
                        }
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                    Text(Post.name)
                                        .bold()
                                    Text("\(formattedDate(date: Post.post.date))")
                                
                            }
                            Spacer()
                            Image(systemName: "ellipsis")
                                .bold()
                                .onTapGesture {
                                    //show_OptionSheet.toggle()
                                }
                        }
                        if !Post.post.url_Image.isEmpty {
                             Text(Post.post.title)
                             RoundedRectangle(cornerRadius: 20)
                                 .frame(width: width*0.83, height: 340)
                                 .overlay {
                                     AsyncImage(url: URL(string: Post.post.url_Image)) { image in
                                         image
                                             .resizable()
                                             .aspectRatio(contentMode: .fill )
                                             .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
                                             .clipShape(RoundedRectangle(cornerRadius: 20)
                                             )
                                     } placeholder: {
                                         ProgressView()
                                     }
                                 }
                                 
                                 .offset(x: -5)
                             
                        } else {
                             Text(Post.post.title)
                                 .font(.title)
                                 .offset(y: 5)
                             
                        }
                        
                        
                        HStack(alignment: .top, spacing: 15) {
                            VStack {
                                
//                                Image(systemName: model.isLiked ? "heart.fill" : "heart")
//                                    .resizable()
//                                    .frame(width: 30, height: 30)
//                                    .onTapGesture {
//                                        userReact(post: model.post, value: model.isLiked)
//                                        model.isLiked.toggle()
//                                    }
                                
                            }
                            
                            VStack {
                                Image(systemName: "ellipsis.bubble")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .onTapGesture {
//                                        self.sent = model
//                                        show_commentView.toggle()
                                    }
                            }
                            Image(systemName: "shared.with.you.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                            
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                }
                .paddingHoriZontal()
            }
        }
    }
    
    private func Identification() async throws {
        Task {
            do {
                self.id = try await Authentication.shared.Identification()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func downloadPost() async throws {
        Task {
            do {
                let collection = DataBase.shared.collection_PublicPost
                let identity = try await DataBase.shared.Identification()
                let allPostIdentification = try await DataBase.shared.collection_FriendsPost(id: identity).getDocuments(as: model_PostIdentity.self)
                
                for postID in allPostIdentification {
                    if let post = try await collection.whereField(model_Post.CodingKeys.id.rawValue, isEqualTo: postID.id).getDocuments(as: model_Post.self).first {
                        let signature = try await DataBase.shared.downloadSpecific(id: post.signature)
                        let model = postShowModel(name: signature.first?.name ?? "", imageURL: signature.first?.url_profilePicture ?? "", post: post)
                        self.postCatchModel.setValue(model, forKey: postID.id)
//                        self.postCache.setValue(post, forKey: postID.id)
                        
                    }
                }
//                shareAllKeys(model: postCatchModel.allKeys)
                shareAllKeys(model: allPostIdentification)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func formattedDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd, MMMM, yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func shareAllKeys(model : [String]) {
        for item in model {
            self.allKeys.append(item)
        }
    
    }
    
    private func shareAllKeys(model : [model_PostIdentity]) {
        for item in model {
            self.allKeys.append(item.id)
        }
    
    }
    
    private func CheckValidity(model1: [String], model2: [model_PostIdentity]) {
        for index in 0...model1.count {
            if model1[index] == model2[index].id {
                print("match")
            } else {
                print("not match")
            }
            
        }
    }
    
    private func printAllCache(model : LRUCache<String, model_Post>) {
        let allkey = model.allKeys
        let allValue = model.allValues
        print(allkey)
        print(allValue)
    }
    
    private func Position(position: String) {
        print(position)
    }
    
    
    
    
}


struct testView: View {
    var body: some View {
        TabView {
            Alternative_NewsFeed_View()
                .tabItem {
                    Text("view 1")
                }
            News_Feed()
                .tabItem { Text("view 2") }
        }
    }
}


#Preview {
    //Alternative_NewsFeed_View()
    testView()
}
