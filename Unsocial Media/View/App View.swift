//
//  App View.swift
//  Unsocial Media
//
//  Created by  Sadi on 11/4/24.
//

import SwiftUI

struct App_View: View {
    var body: some View {
        TabView {
            News_Feed()
                .tabItem {
                    Image(systemName: "newspaper")
                        Text("Feed")
                }
            All_Friends_View()
                .tabItem {
                    Image(systemName: "shareplay")
                        Text("Find Friends")
                }
            Post_View()
                .tabItem {
                    Image(systemName: "signpost.right.and.left")
                        Text("Post")
                }
            Notification_View()
                .tabItem {
                    Image(systemName: "bell.badge.waveform.fill")
                        Text("Notify")
                }
            Users_Profile_View()
                .tabItem {
                    Image(systemName: "gearshape.arrow.triangle.2.circlepath")
                        Text("Profile")
                }
        }
        .tint(Color.white)
        
    }
}

#Preview {
    App_View()
}

