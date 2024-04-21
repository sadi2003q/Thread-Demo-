//
//  Login View.swift
//  Unsocial Media
//
//  Created by  Sadi on 26/3/24.
//

import SwiftUI

struct Login_View: View {
    
    @Binding var successFull : Bool
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var width : CGFloat = { UIScreen.main.bounds.width }()
    @State private var height : CGFloat = { UIScreen.main.bounds.height }()
    
    var body: some View {
        Rectangle()
            .fill(Color.loginBackground)
            .ignoresSafeArea()
            .overlay {
                ScrollView{
                    VStack {
                        _Picture
                        _Email_Password
                        _button_login
                        Spacer()
                    }
                }
                
                .ignoresSafeArea(edges: .top)
            }
            .fullScreenCover(isPresented: $successFull, content: {
                App_View()
            })
            .nav()
        
            
            
        
    }
    
    private var _Picture: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: width, height: height*0.6)
            .overlay {
                Image(.login)
                    .resizable()
                    .scaledToFill()
                    
            }
            .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
    }
    
    private var _Email_Password: some View {
        Group {
            TextField("", text: $email, prompt: Text("Email").foregroundStyle(Color.white))
                .textFieldStyle(UnderlinedTextFieldStyle())
                .padding()
                .padding(.horizontal)
                
                
            
            TextField("", text: $password, prompt: Text("Password").foregroundStyle(Color.white))
                .textFieldStyle(UnderlinedTextFieldStyle())
                .padding()
                .padding(.horizontal)
            
        }
        .foregroundStyle(Color.white)
    }
    
    private var _button_login: some View {
        VStack {
            Button {
                Task {
                    try await login(with: email, and: password)
                }
            } label: {
                Rectangle()
                    .frame(width: 300, height: 60)
                    .overlay {
                        Text("Login")
                            .foregroundStyle(Color.white)
                            .font(.title2)
                            .bold()
                    }
                    .cornerRadius(18, corners: [.topLeft, .topRight, .bottomLeft])
                    
            }
            .padding(.top)
        }
    }
    
}

extension Login_View {
    private func login(with email: String, and password: String) async throws {
        do {
            try await Authentication.shared.Login_Account(with: email, and: password)
            self.successFull = true
        } catch let error {
            print("error : \(error.localizedDescription) \n\n\n")
        }
    }
}



#Preview {
    Login_View(successFull: .constant(false))
}
