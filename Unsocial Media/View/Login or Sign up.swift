//
//  Login or Sign up.swift
//  Unsocial Media
//
//  Created by  Sadi on 11/4/24.
//

import SwiftUI

struct Login_or_Sign_up: View {
//    @AppStorage("authentication") var authenticate : Bool = false
    @State var authenticate : Bool = false
    @State private var show_login: Bool = false
    @State private var show_signIn: Bool = false
    
    
    var body: some View {
        ZStack {
            Color.loginBackground.ignoresSafeArea()
            VStack (spacing: 30) {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.loginForeground, style: StrokeStyle(lineWidth: 7))
                    .frame(width: 250, height: 80)
                    .overlay {
                        Text("Login")
                            .font(.title)
                            .bold()
                            .foregroundStyle(Color.loginForeground)
                    }
                    .onTapGesture {
                        show_login.toggle()
                    }
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.loginForeground)
                    .frame(width: 250, height: 80)
                    .overlay {
                        Text("SignUp")
                            .font(.title)
                            .bold()
                            .foregroundStyle(Color.loginBackground)
                    }
                    .onTapGesture {
                        show_signIn.toggle()
                    }
                    
            }
        }
        .fullScreenCover(isPresented: $show_login, content: {
            Login_View(successFull: $authenticate)
        })
        .fullScreenCover(isPresented: $show_signIn, content: {
            Sign_In_View(successFull: $authenticate)
        })
        
         
    }
}

#Preview {
    Login_or_Sign_up()
}
