import Vapor
import SwiftLogger

// MARK: Flow
func routeChatServer(_ app: Application) throws {
    // 확인 - GET /
    app.get { req async in
        "This is TestServer. Welcome!"
    }
    
    // 회원가입 - POST /register
    app.post("register") { req async throws -> HTTPStatus in
        let credential = try req.content.decode(Credential.self)
        
        
        let chatServerRef = await ChatServer.shared
        
        await chatServerRef.register(credential: credential)
        
        return .accepted
    }
    
    
    // 인증 - POST /auth
    app.post("auth") { req async throws -> Bool in
        let credential = try req.content.decode(Credential.self)
        
        // flow
        let chatServerRef = await ChatServer.shared
        let identified = await chatServerRef.isExist(email: credential.email,
                                                     password: credential.password)
        
        return identified
    }
    
    
    // 전체 메시지 조회 - GET /getMessages
    app.get("getMessages") { req async throws -> [Message] in
        let credential: Credential
        if let email = req.query[String.self, at: "email"],
           let password = req.query[String.self, at: "password"] {
            credential = Credential(email: email, password: password)
        } else if let body = req.body.data, body.readableBytes > 0 {
            credential = try req.content.decode(Credential.self)
        } else {
            req.logger.error("요청에 email/password가 포함되지 않았습니다.")
            throw Abort(.badRequest)
        }
        let chatServerRef = await ChatServer.shared
        let identified = await chatServerRef.isExist(email: credential.email,
                              password: credential.password)

        guard identified else {
            req.logger.error("인증되지 않은 사용자의 요청입니다.")
            return []
        }
        
        // flow
        return await chatServerRef.messages.sorted(using: KeyPathComparator(\.createdAt))
    }
    
    
    // 메시지 전송 - POST /addMessage
    app.post("addMessage") { req async throws -> HTTPStatus in
        let ticket = try req.content.decode(NewMsgTicket.self)
        let credential = ticket.credential
        let chatServerRef = await ChatServer.shared
        let identified = await chatServerRef.isExist(email: credential.email,
                              password: credential.password)
        
        guard identified else {
            req.logger.error("인증되지 않은 사용자의 요청입니다.")
            return .unauthorized
        }
        
        // flow
        await chatServerRef.addMessageTiket(ticket)
        await chatServerRef.processMessageTickets()
        
        let newMessageEvent = NewMsgEvent(client: ticket.client, senderEmail: ticket.credential.email, content: ticket.content)
        await chatServerRef.sendEvent(newMessageEvent)
        
        return .accepted
    }
    
    // 구독 - POST /subscribe?client={UUID}
    // http://127.0.0.1:8080/subscribe?client=(UUID 값)
    app.post("subscribe") { req async throws -> HTTPStatus in
        req.logger.info("Subscribe가 호춛되었습니다.")
        
        guard let token = req.query[String.self, at: "client"] else {
            req.logger.error("Client에서 ClientID가 전달되지 않았습니다.")
            return .badRequest
        }
        
        guard let clientId = UUID(uuidString: token) else {
            req.logger.error("Token이 UUID 형식이 아닙니다.")
            return .badRequest
        }
        
        // flow
        let chatServerRef = await ChatServer.shared
        
        await MainActor.run {
            chatServerRef.subscribers[clientId] = .shared
        }
        
        return .accepted
    }
}
