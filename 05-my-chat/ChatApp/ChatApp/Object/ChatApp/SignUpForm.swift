//
//  SignUpForm.swift
//  ChatApp
//
//  Created by 김민우 on 11/6/25.
//
import Foundation
import Observation
import SwiftLogger

private let logger = SwiftLogger("SignUpForm")


// MARK: Object
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
        logger.start()
        
        let emailValue = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordValue = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordCheckValue = passwordCheck.trimmingCharacters(in: .whitespacesAndNewlines)
        let flow = owner.serverFlow
        
        guard emailValue.isEmpty == false else {
            logger.error("Email is empty")
            return
        }
        guard passwordValue.isEmpty == false else {
            logger.error("Password is empty")
            return
        }
        guard passwordValue == passwordCheckValue else {
            logger.error("Password and confirmation do not match")
            return
        }
        
        let credential = Credential(email: emailValue, password: passwordValue)
        do {
            try await flow.register(credential: credential)
        } catch {
            logger.error("Registration failed: \(error)")
            return
        }
        do {
            let identified = try await flow.authenticate(credential: credential)
            guard identified else {
                logger.error("Authentication failed right after register")
                return
            }
            
            owner.credential = credential
            owner.signInForm = nil
            owner.signUpForm = nil

        } catch {
            logger.error("Post-registration authentication failed: \(error)")
        }
    }
}
