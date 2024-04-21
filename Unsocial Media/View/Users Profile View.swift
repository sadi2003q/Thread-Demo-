//
//  Users Profile View.swift
//  Unsocial Media
//
//  Created by  Sadi on 22/3/24.
//

import SwiftUI

struct Users_Profile_View: View {
    
    @State private var width : CGFloat = { UIScreen.main.bounds.width }()
    @State private var height : CGFloat = { UIScreen.main.bounds.height }()
    
    @State private var showUsers_Activities: Int = 1
    @State private var model : [model_SignIn] = []
    @State private var post : [model_Post] = []
    
    var body: some View {
        ZStack {
            Color.loginBackground.ignoresSafeArea()
            VStack {
                _Users_Profile
                _button_Edit
                _button_SubSection
               
                _Subsection_Content
            }
            .foregroundStyle(Color.white)
        }
            .onAppear {
                Task {
                    try await download_PersonalInformation()
                    try await DownloadPost()
                }
            }
        
        
        
    }
    
    private var _Users_Profile : some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                
                Text("\(model.first?.name ?? "no name")")
                    
                    .bold()
                Text("imSadi20")
                    .padding(.bottom, 20)
                
                
                Text("Hy every one, I am Sadi")
                    .padding(.bottom, 20)
                
                Text("2 Followers")
                    .opacity(0.5)
            }
            
            Spacer()
            
            Circle()
                .frame(width: 125, height: 125)
                .overlay {
                    if let url = model.first?.url_profilePicture {
                        AsyncImage(url: URL(string: url)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                                .foregroundStyle(Color.white)
                        }

                    } else {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                    }
                }
            
        }
        .padding(.horizontal)
        .padding(.top, 60)
    }
    
    private var _button_Edit: some View {
        HStack {
            Button {
                
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 3))
                    .frame(width: 150, height: 50)
                    .overlay {
                        Text("Edit Profile")
                    }
                    
            }
            Button {
                
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 3))
                    .frame(width: 150, height: 50)
                    .overlay {
                        Text("Share Profile")
                    }
                    
            }
        }
        
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
    
    private var _Subsection_content_Uploads: some View {
            GeometryReader{ geometry in
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: geometry.size.width)
            }
        
    }
    
    private var _Subsection_content_Status: some View {
        GeometryReader{ geometry in
            Rectangle()
                .fill(Color.red)
                .frame(width: geometry.size.width)
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
                            if let url = self.model.first?.url_profilePicture {
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
    
    private var _ProfileInformation: some View {
        VStack(alignment : .leading) {
            Text("Name : \(model.first?.name ?? "" )")
            Text("Email : \(model.first?.email ?? "" )")
            Text("Gender : \(model.first?.gender ?? "" )")
        }
        .padding(.top, 50)
        .font(.title)
        .bold()
        .foregroundStyle(Color.white)
    }
    
    
}

extension Users_Profile_View {
    private func download_PersonalInformation() async throws {
        Task {
            do {
                self.model = try await DataBase.shared.Download_PersonalInformation()
            } catch let error {
                print("error : \(error.localizedDescription)")
            }
        }
    }
    
    private func DownloadPost() async throws {
        Task {
            do {
                let id = try await DataBase.shared.Identification()
                let allPostIdentification = try await DataBase.shared.collection_FriendsPost(id: id).getDocuments(as: model_PostIdentity.self)
                for identification in allPostIdentification {
                    self.post.append(contentsOf: try await DataBase.shared.collection_PublicPost.whereField(model_Post.CodingKeys.id.rawValue, isEqualTo: identification.id).getDocuments(as: model_Post.self))
                    
                    print("count : \(post.count)")
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
}

#Preview {
    Users_Profile_View()
}


