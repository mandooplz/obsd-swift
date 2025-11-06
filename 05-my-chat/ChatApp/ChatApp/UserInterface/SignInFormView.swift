//
//  SignInFormView.swift
//  ChatApp
//
//  Created by 김민우 on 11/5/25.
//

import SwiftUI
import Observation


// MARK: View
struct SignInFormView: View {
    // MARK: state
    @Bindable var form: SignInForm
    @State private var isSubmitting = false
    
    
    // MARK: body
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

            Section {
                NavigationLink {
                    if let form = form.owner.signUpForm {
                        SignUpFormView(form: form)
                            .navigationTitle("회원가입")
                    } else {
                        ProgressView()
                            .padding()
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("아직 계정이 없으신가요?")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Text("회원가입 하러 가기")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private func submit() {
        Task { 
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
