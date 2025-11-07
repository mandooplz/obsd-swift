//
//  SignInForm.swift
//  ChatApp
//
//  Created by 김민우 on 11/4/25.
//
import Foundation
import Observation
import SwiftLogger

private let logger = SwiftLogger("SignInForm")


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
        logger.start()
        
        // capture
        let emailValue = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordValue = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let flow = owner.serverFlow
        
        guard emailValue.isEmpty == false else {
            logger.error("Email이 빈값입니다.")
            return
        }
        guard passwordValue.isEmpty == false else {
            logger.error("Password가 빈값입니다.")
            return
        }
        

        do {
            // compute
            let credential = Credential(email: emailValue, password: passwordValue)
            let identified = try await flow.authenticate(credential: credential)
            guard identified else {
                logger.error("Authentication failed - \(identified)")
                return
            }
            
            // mutate
            owner.credential = credential
            owner.signInForm = nil
            owner.signUpForm = nil
        } catch {
            logger.error("Authentication request failed: \(error)")
        }
    }
}



