//
//  ChatRootView.swift
//  ChatApp
//
//  Created by 김민우 on 11/5/25.
//

import SwiftUI
import Observation


// MARK: View
struct ChatAppView: View {
    // MARK: model
    @State private var app = ChatApp()
    
    // MARK: body
    var body: some View {
        ZStack {
            if app.credential != nil {
                ChatRoomView(app: app)
            } else if let form = app.signInForm {
                NavigationStack {
                    SignInFormView(form: form)
                        .navigationTitle("로그인")
                }
            } else {
                ProgressView()
            }
        }
        .task {
            await app.setUp()
        }
    }
}


#Preview {
    ChatAppView()
}
