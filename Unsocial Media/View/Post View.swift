//
//  Post View.swift
//  Unsocial Media
//
//  Created by  Sadi on 1/4/24.
//

import SwiftUI
import PhotosUI
import SwiftfulFirestore
struct Post_View: View {
    
    @State private var text: String = ""
    @State private var isFocus : Bool = true
    
    
    @State private var photosPicker: PhotosPickerItem?
    @State private var image: UIImage? = nil
    @State private var imageURL : String = ""
    
    
    @State private var width : CGFloat = { UIScreen.main.bounds.width }()
    @State private var height : CGFloat = { UIScreen.main.bounds.height }()
    
    
    @State private var showAlert: Bool = false
    @State private var errorMessage: String = ""
    
    @State private var currentUser: [model_SignIn] = []
    @State private var allFollower: [model_PublicInformation] = []

    
    var body: some View {
        Rectangle()
            .fill(Color.loginBackground)
            .ignoresSafeArea()
            .overlay {

                _TextBox
                
            }
            .onChange(of: photosPicker) { oldValue, newValue in
                Task {
                    if let photosPicker,
                       let data = try? await photosPicker.loadTransferable(type: Data.self) {
                        if let convertedImage = UIImage(data: data) {
                            self.image = convertedImage
                        }
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .cancel(Text("Retry")) {
                        errorMessage = ""
                        showAlert.toggle()
                    }
                )


            }
            .onAppear {
                
                Task {
                    try await DownloadAllFollower()
                    try await CurrentUser()
                }
            }

        
    }
    
    private var _TextBox: some View {
        
        VStack {
            HStack(alignment: .top) {
                Circle()
                    .fill(Color.foreground)
                    .frame(width: 60, height: 60)
                    .overlay {
                        if currentUser.first?.url_profilePicture != "" {
                            AsyncImage(url: URL(string: currentUser.first?.url_profilePicture ?? "")) { image in
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
                    Text(currentUser.first?.name ?? "no name")
                        .font(.title2)
                        .bold()
                    VStack (alignment: .leading) {
                        TextField("", text: $text,
                                  prompt: Text("whats on your mind").foregroundStyle(Color.white.opacity(0.8)) )
                        .textFieldStyle(RoundedTextFieldStyle(color: Color.clear))
                        .frame(minHeight: 40)
                        .offset(x: -25, y: -12)
                        
                        if let image {
                            _image(image: image)
                        }
                        
                        
                        HStack(spacing: 20) {
                            PhotosPicker(selection: $photosPicker) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                            }
                            Image(systemName: "camera.shutter.button")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Image(systemName: "waveform")
                                .resizable()
                                .frame(width: 30, height: 30)
                            
                            Spacer()
                            
                            Button {
                                Task {
                                    try await UploadPost()
                                }
                            } label: {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .frame(width: 70, height: 40)
                                    .overlay {
                                        HStack(spacing: 2) {
                                            Text("Post")
                                            Image(systemName: "paperplane.fill")
                                        }
                                        .foregroundStyle(Color.black)
                                    }
                            }
                            .disabled(text.isEmpty && image == nil ? true : false)
                        }
                        .foregroundStyle(Color.white.opacity(0.7))
                        .padding(.vertical, 3)
                    }
                }
                
                Spacer()
                
            }
            .padding(.horizontal)
            
            
        }
        
        .foregroundStyle(Color.white)
    }
    
    private func _image(image: UIImage) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .frame(width: width*0.76, height: 340)
            .overlay {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
            }
    }
    
    private func DownloadAllFollower() async throws {
        Task {
            do {
                print("start")
                let id = try await Authentication.shared.Identification()
                let collection = DataBase.shared.collection_PersonalFollowing(id: id)
                for try await following : [model_PublicInformation] in  collection.streamAllDocuments(onListenerConfigured: { _ in }) {
                    self.allFollower = following
                    print("Ending Function")
                    print("count : \(self.allFollower.count)")
                }
                
                
                
            } catch let error {
                print("error : \(error.localizedDescription)")
            }
        }
    }
    
    private func UploadPost() async throws {
        Task {
            do {
                let id = try await DataBase.shared.Identification()
                let UID = UUID().uuidString
                let user = try await DataBase.shared.Download_PersonalInformation()
                
                if let image {
                    self.imageURL = try await Store.shared.Upload_getURL(the: image).absoluteString
                }
                
                try await DataBase.shared.Upload_Post(model: model_Post(id: UID, signature: id, name: user.first?.name ?? "no name", title: text, url_Image: imageURL, date: Date()))
                
                for follower in allFollower {
                    
                    try await DataBase.shared.collection_FriendsPost(id: follower.id).setDocument(document: model_PostIdentity(id: UID, postAccount: id))
                }
                text = ""
                imageURL = ""
                image = nil
                
                
            } catch let error {
                print("error : \(error.localizedDescription)")
            }
        }
    }
    
    private func CurrentUser() async throws {
        Task {
            do {
                self.currentUser = try await DataBase.shared.Download_PersonalInformation()
            } catch let error {
                
                self.errorMessage = error.localizedDescription
                self.showAlert.toggle()
            }
        }
    }
    
    
    
    

}



#Preview {
    Post_View()
}
