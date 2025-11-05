//
//  SignInForm.swift
//  ChatApp
//
//  Created by 김민우 on 11/4/25.
//
import Foundation
import Observation
import SwiftLogger

private let signInLogger = SwiftLogger("SignInForm")
private let signUpLogger = SwiftLogger("SignUpForm")


// MARK: Object
@MainActor @Observable
public final class SignInForm: Sendable {
    // MARK: core
    init(owner: ChatApp) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let owner: ChatApp
    var email: String = ""
    var password: String = ""
    
    
    // MARK: action
    func signIn() async {
        signInLogger.start()
        
        let emailValue = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordValue = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let flow = owner.serverFlow
        
        guard emailValue.isEmpty == false else {
            signInLogger.error("Email is empty")
            return
        }
        guard passwordValue.isEmpty == false else {
            signInLogger.error("Password is empty")
            return
        }
        
        let credential = Credential(email: emailValue, password: passwordValue)
        do {
            let identified = try await flow.authenticate(credential: credential)
            guard identified else {
                signInLogger.error("Authentication failed")
                return
            }
            await owner.completeAuthentication(with: credential)
        } catch {
            signInLogger.error("Authentication request failed: \(error)")
        }
    }
}


@MainActor @Observable
public final class SignUpForm: Sendable {
    // MARK: core
    init(owner: ChatApp) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let owner: ChatApp
    var email: String = ""
    var password: String = ""
    var passwordCheck: String = ""
    
    
    // MARK: action
    func signUp() async {
        signUpLogger.start()
        
        let emailValue = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordValue = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordCheckValue = passwordCheck.trimmingCharacters(in: .whitespacesAndNewlines)
        let flow = owner.serverFlow
        
        guard emailValue.isEmpty == false else {
            signUpLogger.error("Email is empty")
            return
        }
        guard passwordValue.isEmpty == false else {
            signUpLogger.error("Password is empty")
            return
        }
        guard passwordValue == passwordCheckValue else {
            signUpLogger.error("Password and confirmation do not match")
            return
        }
        
        let credential = Credential(email: emailValue, password: passwordValue)
        do {
            try await flow.register(credential: credential)
        } catch {
            signUpLogger.error("Registration failed: \(error)")
            return
        }
        do {
            let identified = try await flow.authenticate(credential: credential)
            guard identified else {
                signUpLogger.error("Authentication failed right after register")
                return
            }
            await owner.completeAuthentication(with: credential)
        } catch {
            signUpLogger.error("Post-registration authentication failed: \(error)")
        }
    }
}
