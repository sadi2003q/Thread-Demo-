//
//  All Friends View.swift
//  Unsocial Media
//
//  Created by  Sadi on 3/4/24.
//

import SwiftUI

struct All_Friends_View: View {
    
    @State private var allUser : [model_PublicInformation] = []
    @State private var myFollowing: [model_PublicInformation] = []
    
    @State private var id: String = ""
    
    @State private var searchTerm : String = ""
    
    @State private var show_specificProfile: Bool = false
    
    var accounts : [model_PublicInformation] {
        guard !searchTerm.isEmpty else { return allUser }
        return allUser.filter { $0.name.localizedCaseInsensitiveContains (searchTerm) }
    }
    
    var body: some View {
        ZStack {
            Color.loginBackground.ignoresSafeArea()
            _allUserView
        }
        .onAppear {
            Task {
                try await Identification()
                try await DownloadAllUser()
            }
        }
        .searchable(text: $searchTerm, placement: .automatic, prompt: Text("search User"))
        .foregroundStyle(Color.white)
        
        .nav()
        
    }
    
    private var _allUserView : some View {
         
        ScrollView {
            ForEach(accounts, id: \.self) { user in
                NavigationLink {
                    SpecificProfile(id: user.id)
                } label: {
                    HStack {
                        
                        Circle()
                            .frame(width: 70, height: 70)
                            .overlay {
                                if !user.url_Image.isEmpty {
                                    AsyncImage(url: URL(string: user.url_Image)) { image in
                                        image
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                        
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                            }
                        
                        Text(user.name)
                            .font(.title)
                            .multilineTextAlignment(.leading)
                            .bold()
                        Spacer()
                    }
                }

                
                
                .padding(.horizontal, 20)
                .foregroundStyle(Color.white)
            }
        }
        
    }
    
}

extension All_Friends_View {
    
    private func Identification() async throws {
        Task {
            do {
                self.id = try await Authentication.shared.Identification()
            } catch let error {
                print("error : \(error.localizedDescription)")
            }
        }
    }
    
    private func DownloadAllUser() async throws {
        
        let collection = DataBase.shared.collection_PublicInformation
        for try await friends : [model_PublicInformation] in collection.streamAllDocuments(onListenerConfigured: { _ in }) {
            self.allUser = friends
            removeMyAccount()
        }
        
        
    }
    
    private func follow(model: model_PublicInformation) async throws {
        Task {
            do {
                try await DataBase.shared.Follow(model: model)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func removeMyAccount() {
        for (index, friend) in self.allUser.enumerated() {
            if friend.id == id {
                self.allUser.remove(at: index)
                break
            }
        }
    }
    
}

struct SpecificProfile: View {
    
    @State private var width : CGFloat = { UIScreen.main.bounds.width }()
    @State private var height : CGFloat = { UIScreen.main.bounds.height }()
    
    @State var id: String
    @State private var post : [model_Post] = []
    @State private var following: [model_PublicInformation] = []
    @State private var isFollowed : Bool = false
    
    
    @State private var account: [model_SignIn] = []
    @State private var showUsers_Activities: Int = 1
    
    
    var body: some View {
        ZStack {
            Color.loginBackground.ignoresSafeArea()
            _accountSHow
        }
        .onAppear {
            Task {
                try await DownloadInformation(id: id)
                try await FollowingAccount()
                try await DownloadPost()
            }
            
        }
        .onChange(of: following) { oldValue, newValue in
            if following.count != 0 && account.count != 0 {
                isFollowedAccount()
            }
        }
    }
    
    private var _postShow: some View {
        ScrollView {
            ForEach(post, id: \.self) { model in
                HStack(alignment: .top) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                        .overlay {
                            if let url = account.first?.url_profilePicture {
                                AsyncImage(url: URL(string: url)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill )
                                        .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
                                        .clipShape(Circle())
                                        
                                } placeholder: {
                                    ProgressView()
                                }

                            }
                            
                        }
                        
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment : .leading) {
                                Text(model.name)
                                    .bold()
                                Text(formattedDate(date: model.date))
                            }
                            Spacer()
                            Image(systemName: "circle.fill")
                        }
                        if !model.url_Image.isEmpty {
                            Text(model.title)
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: width*0.83, height: 340)
                                .overlay {
                                    AsyncImage(url: URL(string: model.url_Image)) { image in
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
                            Text(model.title)
                                .font(.title)
                        }
                        
                        Rectangle()
                            .frame(width: 250, height: 3)
                    }
                }
                .foregroundStyle(Color.white)
                .padding(.horizontal)
            }
            
        }
    }
    
    private var _accountSHow: some View {
        ScrollView{
            VStack {
                Circle()
                    .frame(width: 200, height: 200)
                    .overlay {
                        AsyncImage(url: URL(string: account.first?.url_profilePicture ?? "" )) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }

                    }
                HStack {
                    Text(account.first?.name ?? "no name")
                        .font(.title)
                        .bold()
                        .foregroundStyle(Color.white)
                    Image(systemName: isFollowed ? "person.crop.circle.fill.badge.checkmark" : "person.crop.circle.fill.badge.plus")
                        .foregroundStyle(Color.blue)
                        .font(.title)
                }
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 250, height: 70)
                    .cornerRadius(20, corners: [.topLeft, .topRight, .bottomLeft])
                    .overlay {
                        Text( isFollowed ? "Following" : "Follow")
                            .foregroundStyle(Color.white)
                    }
                    .onTapGesture {
                        Task {
                            if let identity = account.first {
                                if !isFollowed {
                                    try await follow(model: model_PublicInformation(id: identity.id, name: identity.name, email: identity.email, url_Image: identity.url_profilePicture))
                                } else {
                                    try await unfollow(id: account.first?.id ?? "" )
                                }
                                
                            }
                            
                        }
                    }
                _button_SubSection
                Spacer()
                _Subsection_Content
                
            }
        }
        
        .padding(.horizontal, 20)
    }
    
    private var _button_SubSection: some View {
        HStack(spacing: 70) {
            Button {
                withAnimation(.spring()) {
                    showUsers_Activities = 1
                }
                
            } label: {
                VStack (spacing: 0) {
                    Text("Uploads")
                        .foregroundStyle(Color.white)
                        .font(.title2)
                    if showUsers_Activities == 1 {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 130, height: 3)
                    }
                    
                }
            }
            Button {
                withAnimation(.spring()) {
                    showUsers_Activities = 2
                }
            } label: {
                VStack (spacing: 0) {
                    Text("Status")
                        .foregroundStyle(Color.white)
                        .font(.title2)
                    if showUsers_Activities == 2 {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 130, height: 3)
                    }
                }
            }
            
        }
        
        .foregroundStyle(Color.foreground)
    }
    
    private var _Subsection_Content: some View {
        HStack {
            if showUsers_Activities == 1 {
                _postShow.transition(.move(edge: .leading))
            } else {
                _ProfileInformation.transition(.move(edge: .trailing))
            }
        }
        
    }
    
    private var _ProfileInformation: some View {
        VStack(alignment : .leading) {
            Text("Name : \(account.first?.name ?? "" )")
            Text("Email : \(account.first?.email ?? "" )")
            Text("Gender : \(account.first?.gender ?? "" )")
        }
        .padding(.top, 50)
        .font(.title)
        .bold()
        .foregroundStyle(Color.white)
    }
    
    private var _Subsection_content_Status: some View {
            Rectangle()
                .fill(Color.red)
                .frame(width: width)
    }
    
    
    
    private func DownloadInformation(id: String) async throws {
        Task {
            do {
                self.account = try await DataBase.shared.downloadSpecific(id: id)
            } catch let error { print(error.localizedDescription) }
        }
    }

    private func FollowingAccount() async throws {
        Task {
            do {
                let id = try await DataBase.shared.Identification()
                self.following = try await DataBase.shared.collection_PersonalFollowing(id: id).getDocuments(as: model_PublicInformation.self)
            } catch let error { throw error }
        }
    }
    
    private func isFollowedAccount() {
        for item in following {
            if item.id == account.first?.id ?? "" {
                print("true")
                self.isFollowed = true
                return
            }
        }
        
        self.isFollowed = false
        print("false")
    }
    
    #warning("collection should be change to My Own Post collection")
    private func DownloadPost() async throws {
        Task {
            do {
                
                let allPostIdentification = try await DataBase.shared.collection_FriendsPost(id: id).getDocuments(as: model_PostIdentity.self)
                for identification in allPostIdentification {
                    self.post.append(contentsOf: try await DataBase.shared.collection_PublicPost.whereField(model_Post.CodingKeys.id.rawValue, isEqualTo: identification.id).getDocuments(as: model_Post.self))
                }
                
            } catch let error {
                print("error : \(error.localizedDescription)")
            }
        }
    }
    
    private func formattedDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd, MMMM, yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func follow(model: model_PublicInformation) async throws {
        Task {
            do {
                let user = try await DataBase.shared.Download_PersonalInformation()
                try await DataBase.shared.Follow(model: model)
                if let u = user.first {
                    try await DataBase.shared.sentNotification(id: account.first?.id ?? "" , custom: .follow, model: u)
                    isFollowed.toggle()
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func unfollow(id: String) async throws {
        Task {
            do {
                let UID = try await DataBase.shared.Identification()
                try await DataBase.shared.collection_PersonalFollowing(id: UID).deleteDocument(id: id)
                isFollowed.toggle()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
}

#Preview {
    All_Friends_View()
//    SpecificProfile(id: "light@test.com")
}
