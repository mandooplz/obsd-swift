//
//  ChatRootView.swift
//  ChatApp
//
//  Created by 김민우 on 11/5/25.
//

import SwiftUI
import Observation


// MARK: UserInterface
struct ChatRootView: View {
    @State private var app = ChatApp()
    @State private var hasLaunched = false
    @State private var selectedAuthTab: AuthTab = .signIn
    
    var body: some View {
        Group {
            if app.credential != nil {
                ChatRoomView(app: app)
            } else {
                authView
            }
        }
        .task {
            guard hasLaunched == false else { return }
            hasLaunched = true
            await app.setUp()
        }
    }
    
    @ViewBuilder
    private var authView: some View {
        NavigationStack {
            VStack {
                Picker("", selection: $selectedAuthTab) {
                    ForEach(AuthTab.allCases, id: \.self) { tab in
                        Text(tab.title).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding([.top, .horizontal])
                
                switch selectedAuthTab {
                case .signIn:
                    if let form = app.signInForm {
                        SignInFormView(form: form)
                    } else {
                        ProgressView().padding()
                    }
                case .signUp:
                    if let form = app.signUpForm {
                        SignUpFormView(form: form)
                    } else {
                        ProgressView().padding()
                    }
                }
            }
            .animation(.default, value: selectedAuthTab)
            .navigationTitle(selectedAuthTab.title)
        }
    }
}

private enum AuthTab: CaseIterable {
    case signIn
    case signUp
    
    var title: String {
        switch self {
        case .signIn:
            return "로그인"
        case .signUp:
            return "회원가입"
        }
    }
}


#Preview {
    ChatRootView()
}
