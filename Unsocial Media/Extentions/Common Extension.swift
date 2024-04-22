//
//  Common Extension.swift
//  Unsocial Media
//
//  Created by  Sadi on 26/3/24.
//

import Foundation
import SwiftUI

extension View {
    func alert(isPresented: Binding<Bool>,
               title: String,
               message: String,
               buttonText: String = "OK",
               action: @escaping () -> Void = {}) -> some View {
        alert(title,
              isPresented: isPresented) {
            Button(buttonText,
                   action: action)
        } message: {
            Text(message)
        }
    }
    
    func alertWithOkAndCancel(isPresented: Binding<Bool>,
                              title: String,
                              message: String,
                              buttonText: String = "OK",
                              cancelButtonText: String = "Cancel",
                              action: @escaping (Bool) -> Void) -> some View {
        alert(title,
              isPresented: isPresented) {
            Button(buttonText) {
                action(true)
            }
            Button(cancelButtonText) {
                action(false)
            }
        } message: {
            Text(message)
        }
    }
}



struct UnderlinedTextFieldStyle: TextFieldStyle {
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical, 15)
            .background(
                VStack {
                    Spacer()
                    Color(Color.white)
                        .frame(height: 2)
                }
            )
    }
}
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
}
// Custom RoundedCorner shape used for cornerRadius extension above
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
struct RoundedTextFieldStyle: TextFieldStyle {
    @State var color: Color
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical)
            .padding(.horizontal, 24)
            .background(
                Color(color)
            )
            .clipShape(Capsule(style: .continuous))
    }
}

struct CapsuleTextFieldStyle: TextFieldStyle {
    @State var color: Color
    @State var radius: CGFloat
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical)
            .padding(.horizontal, 24)
            .background(
                Color(color)
            )
            .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}
enum DropDownPickerState {
    case top
    case bottom
}
struct DropDownPicker: View {
    
    @Binding var selection: String?
    @State var fontColor : Color
    @State var backgroundColor: Color
    
    
    
    var state: DropDownPickerState = .bottom
    var options: [String]
    var maxWidth: CGFloat = 180
    
    @State var showDropdown = false
    
    @SceneStorage("drop_down_zindex") private var index = 1000.0
    @State var zindex = 1000.0
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack(spacing: 0) {
                
                
                if state == .top && showDropdown {
                    OptionsView()
                }
                
                HStack {
                    Text(selection == nil ? "Select" : selection!)
                        .foregroundStyle(fontColor)//area 1
                    
                    
                    Spacer(minLength: 0)
                    
                    Image(systemName: state == .top ? "chevron.up" : "chevron.down")
                        .font(.title3)
                        .foregroundColor(fontColor)
                        .rotationEffect(.degrees((showDropdown ? -180 : 0)))
                }
                .padding(.horizontal, 15)
                .frame(width: 180, height: 50)
                .background(backgroundColor) // area2
                .contentShape(.rect)
                .onTapGesture {
                    index += 1
                    zindex = index
                    withAnimation(.snappy) {
                        showDropdown.toggle()
                    }
                }
                .zIndex(10)
                
                if state == .bottom && showDropdown {
                    OptionsView()
                }
            }
            .clipped()
            .background(.white)
            .cornerRadius(10)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray)
            }
            .frame(height: size.height, alignment: state == .top ? .bottom : .top)
            
        }
        .frame(width: maxWidth, height: 50)
        .zIndex(zindex)
    }
    
    
    func OptionsView() -> some View {
        VStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                HStack {
                    Text(option)
                    Spacer()
                    Image(systemName: "checkmark")
                        .opacity(selection == option ? 1 : 0)
                }
                .foregroundStyle(selection == option ? Color.primary : Color.gray)
                .animation(.none, value: selection)
                .frame(height: 40)
                .contentShape(.rect)
                .padding(.horizontal, 15)
                .onTapGesture {
                    withAnimation(.snappy) {
                        selection = option
                        showDropdown.toggle()
                    }
                }
            }
        }
        .transition(.move(edge: state == .top ? .bottom : .top))
        .zIndex(1)
    }
}
extension View {
    
    func navTitle(title: String) -> some View {
        NavigationStack {
            self
                .navigationTitle(title)
        }
    }
    
    func nav() -> some View {
        NavigationStack {
            self
        }
    }
    
    func textFieldDesign() -> some View {
        self
            .padding()
            .background(Color.gray.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)
    }
   
    func centerV() -> some View {
        VStack {
            Spacer()
            self
            Spacer()
        }
    }
    
    func centerH() -> some View {
        HStack {
            Spacer()
            self
            Spacer()
        }
    }
    
    func tabItem_bottom(imageName: String, title: String) -> some View {
        NavigationStack {
            self
        }
        .tabItem {
            Image(systemName: imageName)
            Text(title)
        }
            
    }
    
    func paddingLeading() -> some View  { self.padding(.leading) }
    func paddingTrailing() -> some View  { self.padding(.trailing) }
    func paddingHoriZontal() -> some View  { self.padding(.horizontal) }
    func paddingVertical() -> some View  { self.padding(.vertical) }
    
    
}
