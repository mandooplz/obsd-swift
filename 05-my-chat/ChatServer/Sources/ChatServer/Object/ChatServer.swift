//
//  ChatServer.swift
//  ChatServer
//
//  Created by 김민우 on 11/4/25.
//
import Foundation
import SwiftLogger

private let logger = SwiftLogger("ChatServer")
private let sampleIds = Set([IDCard(email: "example@gmail.com", password: "123456")])


// MARK: Object
@MainActor
final class ChatServer: Sendable {
    // MARK: core
    static let shared: ChatServer = .init()
    
    
    // MARK: state
    var idCards: Set<I DCard> = sampleIds
    func isExist(email: String, password: String) -> Bool {
        idCards.first { $0.isMatched(email, password) } != nil
    }
    func register(credential: Credential) {
        guard isExist(email: credential.email, password: credential.password) == false else {
            logger.error("\(credential.email)에 해당하는 사용자가 이미 존재합니다.")
            return
        }
        let idCard = IDCard(email: credential.email, password: credential.password)
        idCards.insert(idCard)
    }
    
    var messages: Set<Message> = []
    var newMessageTickets: Set<NewMsgTicket> = []
    func addMessageTiket(_ ticket: NewMsgTicket) {
        self.newMessageTickets.insert(ticket)
    }
    
    var subscribers: Dictionary<UUID, ClientFlow> = [:]
    func sendEvent(_ event: NewMsgEvent) async {
        logger.start()
        
        await Hub.shared.sendWithout(clientId: event.client, event: event)
    }
    
    
    // MARK: action
    func processMessageTickets() {
        logger.start()
        
        // capture
        guard newMessageTickets.isEmpty == false else { return }
        
        // mutate
        let tickets = newMessageTickets
        newMessageTickets.removeAll()
        
        for ticket in tickets {
            let message = Message(senderEmail: ticket.credential.email,
                                  content: ticket.content,
                                  createdAt: .now)
            messages.insert(message)
        }
    }
    
    
    // MARK: value
    struct ClientFlow: Sendable {
        // MARK: core
        static let shared = ClientFlow()
        private init() { }
        
        // MARK: operator
        func execute(event: NewMsgEvent) -> Void {
            Task {
                let hub = Hub.shared
                
                await hub.sendWithout(clientId: event.client, event: event)
            }
        }
    }
}
