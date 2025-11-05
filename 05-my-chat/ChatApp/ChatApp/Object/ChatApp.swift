//
//  ChatApp.swift
//  ChatApp
//
//  Created by 김민우 on 11/4/25.
//
import Foundation
import Observation
import SwiftLogger

private let logger = SwiftLogger("ChatApp")


// MARK: Object
@MainActor @Observable
final class ChatApp: Sendable {
    // MARK: core
    init() { }


    // MARK: state
    let serverFlow = ChatServerFlow.shared
    let clientId = UUID()
    
    var signInForm: SignInForm? = nil
    var signUpForm: SignUpForm? = nil
    var credential: Credential? = nil
    
    private var messages: Set<Message> = []
    private var sortedMessages: [Message] {
        return messages.sorted(using: SortDescriptor(\.createdAt))
    }
    private var isSubscribed: Bool = false
    
    
    // MARK: action
    func setUp() async {
        logger.start()
        
        // capture
        guard signInForm == nil, signUpForm == nil else {
            logger.error("Auth forms already exist")
            return
        }
        
        signInForm = SignInForm(owner: self)
        signUpForm = SignUpForm(owner: self)
    }
    
    func fetchMessages() async {
        logger.start()
        
        // capture
        guard let credential else {
            logger.error("Credential is missing. Cannot fetch messages.")
            return
        }
        do {
            let remoteMessages = try await serverFlow.getMessages(credential: credential)
            messages = Set(remoteMessages)
        } catch {
            logger.error("Failed to fetch messages: \(error)")
        }
    }
    
    func subscribeServer() async {
        logger.start()
        guard isSubscribed == false else {
            logger.info("Already subscribed to server")
            return
        }
        guard credential != nil else {
            logger.error("Credential missing; subscription aborted")
            return
        }
        
        // compute
        do {
            try await serverFlow.subscribe(
                clientId: clientId,
                onText: { [weak self] textData in
                    Task.detached { [weak self] in
                        await self?.handleIncomingText(textData)
                    }
                },
                onData: { [weak self] data in
                    guard let text = String(data: data, encoding: .utf8) else { return }
                    Task.detached { [weak self] in
                        await self?.handleIncomingText(text)
                    }
                },
                onClose: { [weak self] error in
                    if let error {
                        logger.error("WebSocket closed with error: \(error.localizedDescription)")
                    } else {
                        logger.info("WebSocket closed normally")
                    }
                    Task { @MainActor [weak self] in
                        self?.isSubscribed = false
                    }
                }
            )
            isSubscribed = true
        } catch {
            logger.error("Failed to subscribe: \(error.localizedDescription)")
            isSubscribed = false
        }
    }

    func sendMessage(content: String) async {
        logger.start()
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            logger.info("Attempted to send empty message; ignored")
            return
        }
        guard let credential else {
            logger.error("No credential available for sending message")
            return
        }
        let ticket = NewMsgTicket(client: clientId,
                                  credential: credential,
                                  content: trimmed)
        do {
            try await serverFlow.addMessage(ticket: ticket)
            await fetchMessages()
        } catch {
            logger.error("Failed to send message: \(error.localizedDescription)")
        }
    }


    // MARK: value
    @MainActor
    private func handleIncomingText(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let event = try? decoder.decode(NewMsgEvent.self, from: data) else {
            return
        }
        guard event.client != clientId else { return }
        Task { await self.fetchMessages() }
    }

    var messageTimeline: [Message] {
        sortedMessages
    }

    func completeAuthentication(with credential: Credential) async {
        self.credential = credential
        signInForm = nil
        signUpForm = nil
        isSubscribed = false
        await fetchMessages()
        await subscribeServer()
    }
}
