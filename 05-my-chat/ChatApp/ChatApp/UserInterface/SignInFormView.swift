//
//  SignInFormView.swift
//  ChatApp
//
//  Created by 김민우 on 11/5/25.
//

import SwiftUI
import Observation


// MARK: UserInterface
struct SignInFormView: View {
    @Bindable var form: SignInForm
    @State private var isSubmitting = false
    
    var body: some View {
        Form {
            Section("계정 정보") {
                TextField("이메일", text: $form.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                SecureField("비밀번호", text: $form.password)
            }
            
            Section {
                Button(action: submit) {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Text("로그인")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(isSubmitting)
            }
        }
    }
    
    private func submit() {
        Task { @MainActor in
            guard isSubmitting == false else { return }
            isSubmitting = true
            defer { isSubmitting = false }
            await form.signIn()
        }
    }
}


#Preview {
    NavigationStack {
        SignInFormView(form: SignInForm(owner: ChatApp()))
            .navigationTitle("로그인")
    }
}


// MARK: UserInterface
struct SignUpFormView: View {
    @Bindable var form: SignUpForm
    @State private var isSubmitting = false
    
    var body: some View {
        Form {
            Section("회원 정보") {
                TextField("이메일", text: $form.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                SecureField("비밀번호", text: $form.password)
                SecureField("비밀번호 확인", text: $form.passwordCheck)
            }
            
            Section {
                Button(action: submit) {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Text("회원가입")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(isSubmitting)
            }
        }
    }
    
    private func submit() {
        Task { @MainActor in
            guard isSubmitting == false else { return }
            isSubmitting = true
            defer { isSubmitting = false }
            await form.signUp()
        }
    }
}


#Preview("SignUp") {
    NavigationStack {
        SignUpFormView(form: SignUpForm(owner: ChatApp()))
            .navigationTitle("회원가입")
    }
}
