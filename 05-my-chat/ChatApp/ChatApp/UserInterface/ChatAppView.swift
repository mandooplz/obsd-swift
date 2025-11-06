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
        Group {
            if app.credential != nil {
                ChatRoomView(app: app)
            } else {
                authView
            }
        }
        .task {
            await app.setUp()
        }
    }
    
    @ViewBuilder
    private var authView: some View {
        NavigationStack {
            VStack(spacing: 24) {
                signInSection
                
                NavigationLink {
                    signUpSection
                        .navigationTitle("회원가입")
                } label: {
                    Text("회원가입 하러 가기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top)
            .navigationTitle("로그인")
        }
    }

    @ViewBuilder
    private var signInSection: some View {
        if let form = app.signInForm {
            SignInFormView(form: form)
        } else {
            ProgressView()
                .padding()
        }
    }

    @ViewBuilder
    private var signUpSection: some View {
        if let form = app.signUpForm {
            SignUpFormView(form: form)
        } else {
            ProgressView()
                .padding()
        }
    }
}


#Preview {
    ChatAppView()
}
