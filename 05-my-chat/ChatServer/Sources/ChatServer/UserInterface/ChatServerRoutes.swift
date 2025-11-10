import Vapor
import SwiftLogger
import MyChatValues

// MARK: - Routes 
struct ChatServerRoutes: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        // 확인 - GET /
        routes.get("", use: index)

        // 회원가입 - POST /register
        routes.post("register", use: register)

        // 인증 - POST /auth
        routes.post("auth", use: auth)

        // 전체 메시지 조회 - GET /getMessages
        routes.get("getMessages", use: getMessages)

        // 메시지 전송 - POST /addMessage
        routes.post("addMessage", use: addMessage)

        // 구독 - POST /subscribe?client={UUID}
        // http://127.0.0.1:8080/subscribe?client=(UUID 값)
        routes.post("subscribe", use: subscribe)
    }

    // MARK: - Handlers (instance methods)
    private func index(_ req: Request) async throws -> String {
        "This is TestServer. Welcome!"
    }

    private func register(_ req: Request) async throws -> HTTPStatus {
        let credential = try req.content.decode(Credential.self)

        // flow
        let chatServerRef = await ChatServer.shared
        await chatServerRef.register(credential: credential)
        return .accepted
    }

    private func auth(_ req: Request) async throws -> Bool {
        let credential = try req.content.decode(Credential.self)

        // flow
        let chatServerRef = await ChatServer.shared
        let identified = await chatServerRef.isExist(email: credential.email,
                                                     password: credential.password)
        return identified
    }

    private func getMessages(_ req: Request) async throws -> [Message] {
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

        // flow
        let chatServerRef = await ChatServer.shared
        let identified = await chatServerRef.isExist(email: credential.email,
                                                     password: credential.password)

        guard identified else {
            req.logger.error("인증되지 않은 사용자의 요청입니다.")
            return []
        }

        return await chatServerRef.messages.sorted(using: KeyPathComparator(\.createdAt))
    }

    private func addMessage(_ req: Request) async throws -> HTTPStatus {
        let ticket = try req.content.decode(NewMsgTicket.self)
        let credential = ticket.credential

        let chatServerRef = await ChatServer.shared
        let identified = await chatServerRef.isExist(email: credential.email,
                                                     password: credential.password)

        guard identified else {
            req.logger.error("인증되지 않은 사용자의 요청입니다.")
            return .unauthorized
        }

        await chatServerRef.addMessageTiket(ticket)
        await chatServerRef.processMessageTickets()

        let newMessageEvent = NewMsgEvent(client: ticket.client,
                                          senderEmail: ticket.credential.email,
                                          content: ticket.content)
        await chatServerRef.sendEvent(newMessageEvent)

        return .accepted
    }

    private func subscribe(_ req: Request) async throws -> HTTPStatus {
        req.logger.info("Subscribe가 호출되었습니다.")

        guard let token = req.query[String.self, at: "client"] else {
            req.logger.error("Client에서 ClientID가 전달되지 않았습니다.")
            return .badRequest
        }

        guard let clientId = UUID(uuidString: token) else {
            req.logger.error("Token이 UUID 형식이 아닙니다.")
            return .badRequest
        }

        let chatServerRef = await ChatServer.shared
        await MainActor.run {
            chatServerRef.subscribers[clientId] = .shared
        }

        return .accepted
    }
}
