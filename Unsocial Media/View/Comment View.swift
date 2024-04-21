//
//  Comment View.swift
//  Unsocial Media
//
//  Created by  Sadi on 9/4/24.
//

import SwiftUI

struct Comment_View: View {
    
    @State var postShow : postShow
    @Binding var user : [model_SignIn]
    
    @State private var width : CGFloat = { UIScreen.main.bounds.width }()
    @State private var height : CGFloat = { UIScreen.main.bounds.height }()
    
    @State private var react : [reactModel] = []
    @State private var reactCount: Int = -1
    @State private var comment : [commentModel] = []
    
    
    @State private var commentText: String = ""
    
    
    @State private var allList : Bool = false

    var body: some View {
        ZStack {
            Color.loginBackground.ignoresSafeArea(.all)
            VStack {
                _postView
                _commentShow
            }
            
        }
        .onAppear {
            Task {
                try await DownloadAllReact(id:postShow.post.id)
                try await DownloadAllComment(id: postShow.post.id)
            }
        }
        .onChange(of: react) { oldValue, newValue in
            reactCount = react.count
        }
        .sheet(isPresented: $allList, content: {
            LikeList(id: postShow.post.id)
        })
    }
    
    private var _postView : some View {
        ScrollView {
            
            HStack(alignment : .top) {
                Circle()
                    .frame(width: 50, height: 50)
                    .overlay {
                        if let url = postShow.account.first?.url_profilePicture {
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
                            if let name = postShow.account.first?.name {
                                Text(name)
                                    .bold()
                                Text("\(formattedDate(date: postShow.post.date))")
                            }
                        }
                        Spacer()
                        Image(systemName: "ellipsis")
                            .bold()
                            .onTapGesture {
                                
                            }
                    }
                    
                    
                     if !postShow.post.url_Image.isEmpty {
                         Text(postShow.post.title)
                         RoundedRectangle(cornerRadius: 20)
                             .frame(width: width*0.83, height: 340)
                             .overlay {
                                 AsyncImage(url: URL(string: postShow.post.url_Image)) { image in
                                     image.resizable()
                                         .scaledToFill()
                                         .clipShape(RoundedRectangle(cornerRadius: 20))
                                 } placeholder: {
                                     ProgressView()
                                 }
                             }
                             .offset(x: -5)
                         
                     } else {
                         Text(postShow.post.title)
                             .font(.title)
                             .offset(y: 5)
                         
                     }
                     
                    
                    
                    
                    HStack(alignment: .top, spacing: 15) {
                        VStack {
                            
                            Image(systemName: postShow.isLiked ? "heart.fill" : "heart")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .onTapGesture {
                                    userReact(post: postShow.post, value: postShow.isLiked)
                                    Task {
                                        try await DownloadAllReact(id: postShow.id)
                                    }
                                    postShow.isLiked.toggle()
                                }
                            Text(formatNumber(reactCount))
                                .foregroundStyle(Color.white.opacity(0.8))
                                .onTapGesture {
                                    allList.toggle()
                                }
                            
                        }
                        
                        VStack {
                            Image(systemName: "ellipsis.bubble")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .onTapGesture {
                                    
                                    
                                }
                            Text(formatNumber(comment.count))
                                .foregroundStyle(Color.white.opacity(0.8))
                        }
                        
                        
                        
                        
                        
                        Image(systemName: "shared.with.you.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                        
                        Spacer()
                    }
                    
                    _commentBox
                    
                    
                    
                    
                    .padding(.vertical)
                }
            }
            .paddingHoriZontal()
        }
        .foregroundStyle(Color.white)
        
    }
    
    private var _commentBox: some View {
        HStack {
            TextField("", text: $commentText, prompt:
                        Text("make a comment")
                .foregroundStyle(Color.white.opacity(0.7))
            )
            .textFieldStyle(CapsuleTextFieldStyle(color: Color.loginTextField, radius: 15))
            
            Button {
                Task {
                    if let u = user.first {
                        try await add_comment(id: postShow.post.id, model: commentModel(id: postShow.post.id , signature: u.id, name: u.name , comment: commentText) )
                    }
                }
                self.commentText = ""
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .frame(width: 70, height: 40)
                    .overlay {
                        HStack {
                            Text("add")
                            Image(systemName: "paperplane.fill")
                        }
                        .foregroundStyle(Color.black)
                    }
            }
        }
    }
    
    private var _commentShow: some View {
        VStack(alignment: .leading) {
            Text("Comment's")
                .font(.largeTitle)
                .bold()
                .padding(.leading, 40)
                .foregroundStyle(Color.white)
            ScrollView  {
                ForEach(comment, id: \.self) { model in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(model.name)
                                .bold()
                            Text(model.comment)
                            
                        }
                        Spacer()
                    }
                    .padding(.bottom, 15)
                }
                
            }
            .foregroundStyle(Color.white)
            .padding(.horizontal, 30)
            .padding(.leading, 20)
        }
        
        
    }
    
    private func add_comment(id: String, model: commentModel) async throws {
        Task {
            do {
                try await DataBase.shared.addComments(id: id, model: model)
                try await DataBase.shared.sentNotification(id: model.id, custom: .comment, model: user[0])
            } catch let error {
                print("error : \(error.localizedDescription)")
            }
        }
    }
    
    private func DownloadAllReact(id : String) async throws {
        let collection = DataBase.shared.collection_PostReact(post: id)
        self.react = try await collection.getDocuments(as: reactModel.self)
    }
    
    private func DownloadAllComment(id: String) async throws {
        let collection = DataBase.shared.collection_PostComments(post: postShow.post.id)
        for try await comments : [commentModel] in collection.streamAllDocuments(onListenerConfigured: { _ in }) {
            self.comment = comments
        }
    }
    
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
    
    private func userReact(post: model_Post, value: Bool) {
        Task {
            if value {
                try await remove_react(post: post.id, uid: user.first?.id ?? "")
                self.reactCount -= 1
            } else {
                try await add_react(id: post.id, model: reactModel(id: user.first?.id ?? "", name: user.first?.name ?? "" ))
                self.reactCount += 1
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
            r.id == user.first?.id
        }
    }
    
    
}


struct LikeList : View {
    
    @State var id: String
    @State private var react: [reactModel] = []
    @State private var account : [model_SignIn] = []
    
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            _list
        }
        .onAppear {
            Task {
                try await DownloadAllReact(id: id)
            }
        }
        .onChange(of: react) { oldValue, newValue in
            Task {
                try await Users()
            }
        }
    }
    
    
    
    private var _list: some View {
        ScrollView {
            ForEach(account, id: \.self) { model in
                HStack(spacing: 20) {
                    Circle()
                        .frame(width: 50, height: 50)
                        .overlay {
                            AsyncImage(url: URL(string: model.url_profilePicture)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                            } placeholder: {
                                ProgressView()
                            }

                        }
                    Text(model.name)
                    Spacer()
                }
                .padding(.horizontal, 30)
            }
        }
        .foregroundStyle(Color.white)
        .padding(.top, 40)
    }
    
    private func DownloadAllReact(id : String) async throws {
        let collection = DataBase.shared.collection_PostReact(post: id)
        self.react = try await collection.getDocuments(as: reactModel.self)
    }
    
    private func Users() async throws {
        Task {
            for model in react {
                self.account.append(try await DataBase.shared.downloadSpecific(id: model.id )[0])
            }
        }
        
    }
    
    
}



//#Preview {
//    Comment_View()
//}
