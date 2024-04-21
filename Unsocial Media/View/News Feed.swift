//
//  News Feed.swift
//  Unsocial Media
//
//  Created by  Sadi on 31/3/24.
//

import SwiftUI
import Lottie
import LRUCache

struct postShow : Identifiable {
    var id = UUID().uuidString
    var post: model_Post
    var account: [model_SignIn]
    var isLiked : Bool
}


private struct postShowModel: Identifiable, Hashable {
    let id = UUID().uuidString
    let name: String
    let imageURL: String
    let post: model_Post
    let account: [model_SignIn]
    var isLiked : Bool
}

struct News_Feed: View {
    
    @State private var width : CGFloat = { UIScreen.main.bounds.width }()
    @State private var height : CGFloat = { UIScreen.main.bounds.height }()
    
    @State private var id : String = ""
    @State private var currentUser : [model_SignIn] = []
    
    //MARK: VARIABLE
    @State private var Post : [model_Post] = []
    @State private var PostShow: [postShow] = []
    @State private var sent: postShow?
    
    
    @State private var show_OptionSheet = false
    @State private var show_commentView = false
    
    @State private var postID : String = ""
    @State private var index = -1
    
    
    @AppStorage ("isReloading") private var isReloading : Bool = false
    
    
    @State private var postCatchModel = LRUCache<String, postShowModel>()
    @State private var allKeys: [String] = []
    
    init() {
        self.isReloading = false
    }
    
    
    var body: some View {
        ZStack {
            Color.loginBackground.ignoresSafeArea(.all)
            //_postView
            postView
            
        }
        .scrollIndicators(.automatic)
        .background(Color.loginBackground)
        .onAppear {
            Task {
                try await downloadCurrentUser()
                try await Identification()
//                try await DownloadPost()
                if isReloading == false {
                    try await downloadPost()
                    self.isReloading = true
                }
            }
        }
        .onChange(of: Post, { oldValue, newValue in
            Task {
                try await downloadAllInformation(model:Post)
            }
        })
//        .onDisappear {
//            self.PostShow = []
//            self.Post = []
//            
//        }
        .sheet(isPresented: $show_OptionSheet, content: {
            EditionView()
                .presentationDetents([.fraction(0.2)])
        })
        .navigationDestination(isPresented: $show_commentView, destination: {
            if let sent {
                Comment_View(postShow: sent, user: $currentUser)
            }
        })
        .nav()
        
    }
    /*
    private var _postView : some View {
        ScrollView {
            Image(.threadsLogoPNG)
                .resizable()
                .renderingMode(.template)
                .frame(width: 38, height: 45)
                .foregroundStyle(Color.white)
                .padding(10)
            ForEach($PostShow) { $model in
                HStack(alignment : .top) {
                    Circle()
                        .frame(width: 50, height: 50)
                        .overlay {
                            if let url = model.account.first?.url_profilePicture {
                                
                                AsyncImage(url: URL(string: url)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                } placeholder: {
                                    ProgressView()
                                }

                            }
                            
                        }
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                if let name = model.account.first?.name {
                                    Text(name)
                                        .bold()
                                    Text("\(formattedDate(date: model.post.date))")
                                }
                            }
                            Spacer()
                            Image(systemName: "ellipsis")
                                .bold()
                                .onTapGesture {
                                    show_OptionSheet.toggle()
                                }
                        }
                        if !model.post.url_Image.isEmpty {
                             Text(model.post.title)
                             RoundedRectangle(cornerRadius: 20)
                                 .frame(width: width*0.83, height: 340)
                                 .overlay {
                                     AsyncImage(url: URL(string: model.post.url_Image)) { image in
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
                             Text(model.post.title)
                                 .font(.title)
                                 .offset(y: 5)
                             
                        }
                        
                        
                        HStack(alignment: .top, spacing: 15) {
                            VStack {
                                
                                Image(systemName: model.isLiked ? "heart.fill" : "heart")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .onTapGesture {
                                        userReact(post: model.post, value: model.isLiked)
                                        model.isLiked.toggle()
                                    }
                                
                            }
                            
                            VStack {
                                Image(systemName: "ellipsis.bubble")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .onTapGesture {
                                        self.sent = model
                                        show_commentView.toggle()
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
        .foregroundStyle(Color.white)
        
    }
    */
    
    private var postView: some View {
        ScrollView {
            Image(.threadsLogoPNG)
                .resizable()
                .renderingMode(.template)
                .frame(width: 38, height: 45)
                .foregroundStyle(Color.white)
                .padding(10)
            VStack {
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
                                            show_OptionSheet.toggle()
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
                                        
                                        Image(systemName:"heart")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .onTapGesture {
//                                                userReact(post: Post.post, value: Post.isLiked)
                                                show_commentView.toggle()
                                                
                                            }
                                        
                                    }
                                    
                                    VStack {
                                        Image(systemName: "ellipsis.bubble")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .onTapGesture {
                                                self.sent = postShow(post: Post.post, account: Post.account, isLiked: Post.isLiked)
                                                show_commentView.toggle()
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
            .padding(.horizontal)
            .foregroundStyle(Color.white)
        }
        .padding(.horizontal)
        
    }
    
    private func ValuePrint(value: Bool) {
        print(value)
    }
    
}

extension News_Feed {
    
    //MARK: COMMENT AND REACT ADDITION
    private func add_react(id: String, model: reactModel) async throws {
        Task {
            do {
                try await DataBase.shared.addReact(id: id, model: model)
            } catch let error {
                print("error : \(error.localizedDescription)")
            }
        }
    }
    
    private func remove_react(post id: String, uid: String) async throws {
        Task {
            do {
                try await DataBase.shared.removeReact(post: id, user: uid)
            } catch let error {
                print("error : \(error.localizedDescription)")
            }
        }
    }
    
    private func add_comment(id: String, model: commentModel) async throws {
        Task {
            do {
                try await DataBase.shared.addComments(id: id, model: model)
            } catch let error {
                print("error : \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: DOWNLOADING FUNCTION
    private func DownloadPost() async throws {
        Task {
            do {
                let id = try await DataBase.shared.Identification()
                let allPostIdentification = try await DataBase.shared.collection_FriendsPost(id: id).getDocuments(as: model_PostIdentity.self)
                for identification in allPostIdentification {
                    self.Post.append(contentsOf: try await DataBase.shared.collection_PublicPost.whereField(model_Post.CodingKeys.id.rawValue, isEqualTo: identification.id).getDocuments(as: model_Post.self))
                }
                
                
                
                
            } catch let error {
                print("error : \(error.localizedDescription)")
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
                        let react = try await DownloadAllReact(id: postID.id)
                        
                        let signature = try await DataBase.shared.downloadSpecific(id: post.signature)
                        let value = isLikedByUser(model: react)
                        let model = postShowModel(name: signature.first?.name ?? "", imageURL: signature.first?.url_profilePicture ?? "", post: post, account: signature, isLiked: value)
                        self.postCatchModel.setValue(model, forKey: postID.id)
                        
                    }
                }
                shareAllKeys(model: allPostIdentification)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func shareAllKeys(model : [model_PostIdentity]) {
        for item in model {
            self.allKeys.append(item.id)
        }
    
    }

    
    private func DownloadAllComment(id : String) async throws -> [commentModel] {
        
        let collection = DataBase.shared.collection_PostComments(post: id)
        return try await collection.getDocuments(as: commentModel.self)
        
    }
    
    private func DownloadAllReact(id : String) async throws -> [reactModel] {
        let collection = DataBase.shared.collection_PostReact(post: id)
        return try await collection.getDocuments(as: reactModel.self)
    }
    
    private func downloadAllInformation(model: [model_Post]) async throws {
        Task {
            for item in model {
                let account = try await DataBase.shared.downloadSpecific(id: item.signature)
                let react = try await DownloadAllReact(id: item.id)
                let like = isLiked(react: react)
                if !PostShow.contains(where: { $0.post.id == item.id }) {
                    PostShow.append(postShow(post: item, account: account, isLiked: like))
                }
            }
        }
    }
    
    private func isLikedByUser(model: [reactModel]) -> Bool {
        var value = false
        for item in model {
            if id == item.id {
                value = true
                break
            }
        }
        return value
        
        
    }
    
    private func userReact(post: model_Post, value: Bool) {
        Task {
            if value {
                try await remove_react(post: post.id, uid: currentUser.first?.id ?? "")
                try await DataBase.shared.sentNotification(id: post.signature, custom: .like, model: currentUser[0])
            } else {
                try await add_react(id: post.id, model: reactModel(id: currentUser.first?.id ?? "", name: currentUser.first?.name ?? "" ))
            }
        }
        
    }
    
    private func downloadCurrentUser() async throws {
        Task {
            do {
                self.currentUser = try await DataBase.shared.Download_PersonalInformation()
            } catch let error {
                print("error : \(error.localizedDescription)")
            }
        }
    }
    
    private func Identification() async throws {
        Task {
            do {
                self.id = try await Authentication.shared.Identification()
            } catch let error {
                print("error : \(error.localizedDescription)")
            }
            
        }
    }
    
    //MARK: FORMATTING FUNCTION
    private func formattedDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd, MMMM, yyyy"
        return dateFormatter.string(from: date)
    }
    
    func formatNumber(_ number: Int) -> String {
        return String(format: "%02d", number)
    }
    
    private func isLiked(react : [reactModel]) -> Bool {
        return react.contains { r in
            r.id == currentUser.first?.id
        }
    }
    
    
    
    
}


struct EditionView: View {
    
    @State private var width : CGFloat = { UIScreen.main.bounds.width }()
    @State private var height : CGFloat = { UIScreen.main.bounds.height }()
    
    var body: some View {
        Rectangle()
            .fill(Color.black)
            .frame(width: width, height: height)
        
            .ignoresSafeArea()
            .overlay {
                VStack {
                    _button_Save
                    _button_ignore
                }
            }
        
    }
    
    
    private var _button_Save: some View {
        Button {
            
        } label: {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.loginTextField)
                .frame(width: width*0.9, height: 50)
                .overlay {
                    HStack {
                        Text("Save")
                        Spacer()
                        Image(systemName: "square.and.arrow.down.on.square")
                        
                    }
                    .foregroundStyle(Color.white)
                    .paddingHoriZontal()
                    
                }
            
        }
    }
    
    private var _button_ignore: some View {
        Button {
            
        } label: {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.loginTextField)
                .frame(width: width*0.9, height: 50)
                .overlay {
                    HStack {
                        Text("Don't Show")
                        Spacer()
                        Image(systemName: "minus.diamond")
                        
                    }
                    .foregroundStyle(Color.white)
                    .paddingHoriZontal()
                    
                }
            
        }
    }
    
    
    
}


#Preview {
    News_Feed()
    //    EditionView()
}
