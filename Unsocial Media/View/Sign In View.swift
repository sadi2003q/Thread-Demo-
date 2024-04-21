//
//  Sign In VIew.swift
//  Unsocial Media
//
//  Created by  Sadi on 26/3/24.
//

import SwiftUI
import PhotosUI


struct Sign_In_View: View {
    
    @Binding var successFull : Bool
    
    @State private var showAlert: Bool = false
    @State private var errorMessage: String = ""
    
    @State private var success : Bool = false
    
    
    
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var gender: String? = ""
    
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    
    var body: some View {
        Rectangle()
            .fill(Color.loginBackground)
            .ignoresSafeArea()
            .overlay {
                ScrollView {
                    VStack {
                        
                        _title
                        _heading
                        _name_age_gender
                        _email_Password
                        _button_login
                    }
                    .padding(.top, 30)
                }
                
                .padding(.vertical, 20)
                
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
            .fullScreenCover(isPresented: $successFull, content: {
                App_View()
            })
            .nav()
        
    }
    
    private var _title: some View {
        HStack {
            Text("Thread")
                .font(.custom("ArialMT", size: 40))
                .bold()
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.foreground)
                .frame(width: 80, height: 80)
                .overlay {
                    Image(.threadsLogoPNG)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color.background)
                        .padding()
                }
            
        }
        .foregroundStyle(Color.white)
        
        
    }
    
    private var _heading: some View {
        VStack{
            Text("Login to\nYour Account")
                .font(.custom("ArialMT", size: 40))
                .bold()
                .multilineTextAlignment(.center)
                .foregroundColor(Color.background)
                .padding(.vertical, 20)
            
        }
    }
    
    private var _name_age_gender: some View {
        VStack(alignment: .leading) {
            TextField("", text: $name,
                      prompt: Text("User's Name")
                .foregroundStyle(Color.white.opacity(0.8))
            )
            .autocapitalization(.words)
            .padding(.horizontal)
            .textFieldStyle(CapsuleTextFieldStyle(color: Color.loginTextField,
                                                  radius: 10))
            HStack {
                TextField("", text: $age,prompt: Text("age").foregroundStyle(Color.white.opacity(0.8)))
                    .textFieldStyle(CapsuleTextFieldStyle(color: Color.loginTextField, radius: 10))
                    .frame(width: 160)
                    .keyboardType(.numberPad)
                DropDownPicker(selection: $gender, fontColor: Color.white, backgroundColor: Color.loginTextField, state: .top, options:  ["Male", "Female"], maxWidth: 160)
                
                
            }
            .padding(.horizontal)
        }
        .foregroundStyle(Color.white)
    }
    
    private var _email_Password: some View {
        
        VStack {
            TextField("", text: $email,
                      prompt: Text("email")
                .foregroundStyle(Color.white.opacity(0.8))
            )
            TextField("", text: $password,
                      prompt: Text("password")
                .foregroundStyle(Color.white.opacity(0.8))
            )
            
        }
        .foregroundStyle(Color.white)
        .padding(.horizontal)
        .textFieldStyle(CapsuleTextFieldStyle(color: Color.loginTextField,
                                              radius: 10))
        .padding(.vertical, 50)
    }
    
    private var _button_login: some View {
        NavigationLink(destination: Sign_In_UploadImage(successFull: $successFull, name: name, age: age, gender: gender ?? "Male", email: email, password: password)) {
            Rectangle()
                .fill(Color.loginForeground)
                .frame(width: 300, height: 60)
                .cornerRadius(15, corners: [.topLeft, .topRight, .bottomLeft])
                .overlay {
                    HStack {
                        Text("Sign In")
                        Image(systemName: "arrow.right")
                    }
                    .bold()
                    .foregroundStyle(Color.white)
                }
        }
        .disabled( name.isEmpty || age.isEmpty || email.isEmpty || password.isEmpty ? true : false )
    }
    
    
    
    
    
    
}

extension Sign_In_View {
    
    func SignIn(with email: String, and password: String) async throws {
        do {
            try await Authentication.shared.Create_Account(with: email, and: password)
            try await DataBase.shared.Upload_PersonalInformation(users: model_SignIn(id: name+"--"+email, name: name, age: age, gender: gender ?? "Male", email: email, password: password, url_profilePicture: ""))
            print("working")
            success.toggle()
            
        } catch let error {
            print(error.localizedDescription)
            errorMessage = error.localizedDescription
            showAlert.toggle()
        }
    }
    
    
    func Clear_Field() {
        self.age = ""
        self.name = ""
        self.email = ""
        self.password = ""
        self.gender = ""
        
    }
}

struct Sign_In_UploadImage: View {
    
    @Binding var successFull : Bool
    
    @State private var loginSuccess : Bool = false
    
    
    @State private var showAlert: Bool = false
    @State private var errorMessage: String = ""
    
    @State var name: String
    @State var age: String
    @State var gender: String
    @State var email: String
    @State var password: String
    
    @State private var usersInformation: [model_SignIn] = []
    @State private var photosPicker: PhotosPickerItem?
    @State private var image: UIImage? = nil
    @State private var imageUrl: String = ""
     
    
    var body: some View {
        Rectangle()
            .fill(Color.loginBackground)
            .ignoresSafeArea()
            .overlay {
                VStack {
                    Spacer()
                    _welcome_User
                    _Image_Upload
                    Spacer()
                    _button_Continue
                    Spacer()
                }
                .offset(y: 30)
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
            .sheet(isPresented: $loginSuccess, content: {
                EmptyView()
            })
            .nav()
            
    }
    
    private var _welcome_User: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Welcome")
                Text(name)
            }
            VStack(alignment: .leading) {
                Text("Connect..")
                Text("with those who matters most")
                    .font(.title3)
                Text("Share your feelings with friends")
                    .font(.title3)
            }
        }
        .font(.largeTitle)
        .bold()
        .foregroundStyle(Color.white)
        .offset(y: -70)
    }
    
    private var _Image_Upload: some View {
        
        PhotosPicker(selection: $photosPicker) {
            Circle()
                .stroke(Color.loginForeground, style: StrokeStyle(lineWidth: 5))
                .frame(width: 200, height: 200)
                .overlay {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    } else {
                        Image(systemName: "person.circle")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.white)
                    }
                }
        }
        
    }
    
    private var _button_Continue: some View {
        Button {
            Task {
                try await CreateAccount()
            }
        } label: {
            Rectangle()
                .fill(Color.loginForeground)
                .frame(width: 220, height: 60)
                .cornerRadius(15, corners: [.topLeft, .topRight, .bottomLeft])
                .overlay {
                    Text("Continue")
                        .foregroundStyle(Color.white)
                        .font(.title2)
                        .bold()
                }
                
        }
    }
    
}
extension Sign_In_UploadImage {

    private func Upload_Image() async throws {
        guard let image else { return }
        do {
            let url = try await Store.shared.Upload_getURL(the: image)
            let url_String = url.absoluteString
            self.imageUrl = url_String
        } catch let error {
            errorMessage = error.localizedDescription
            showAlert.toggle()
        }
    }
    
    private func CreateAccount() async throws {
        do {
            if image != nil {
                try await Upload_Image()
            }
            try await Authentication.shared.Create_Account(with: email, and: password)
            let id = try await Authentication.shared.Identification()
            try await DataBase.shared.Upload_PersonalInformation(users: model_SignIn(id: id, name: name, age: age, gender: gender, email: email, password: password, url_profilePicture: imageUrl))
            self.successFull.toggle()
        } catch let error {
            self.errorMessage = error.localizedDescription
            showAlert.toggle()
        }
    }
}


#Preview {
    Sign_In_View(successFull: .constant(true))
    //Sign_In_UploadImage(name: "sadi", age: "21", gender: "Male", email: "sadi", password: "sadi")
    
}
