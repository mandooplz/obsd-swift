//
//  ChatRoomView.swift
//  ChatApp
//
//  Created by 김민우 on 11/5/25.
//
import SwiftUI
import Observation
import SwiftLogger
import MyChatValues

private let logger = SwiftLogger("ChatRoomView")


// MARK: View
struct ChatRoomView: View {
    @Bindable var app: ChatApp
    
    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            messageTimeline
            Divider()
            composer
        }
        .task(id: app.credential?.email) {
            await app.fetchMessages()
            await subscribeChatServer()
        }
    }
    
    // F
    private func subscribeChatServer() async {
        let hub = ChatServerHub.shared
        
        // 실행할 Flow
        await hub.setNewMessageFlow { event in
            Task {
                await app.addMsgEvent(event)
                
                await app.processMsgEvents()
            }
        }
        
        
        await hub.setCloseFlow { error in
            Task {
                logger.error(error!)
            }
        }
        
        await hub.connect()
    }
    
}


// MARK: SubView
extension ChatRoomView {
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("채팅방")
                    .font(.title2)
                    .bold()
                if let email = app.credential?.email {
                    Text("로그인: \(email)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding()
    }
    
    private var messageTimeline: some View {
        ScrollViewReader { proxy in
            List(app.sortedMessages, id: \.id) { message in
                MessageRowView(message: message)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .refreshable {
                await app.fetchMessages()
            }
            .task {
                guard let last = app.sortedMessages.last?.id else { return }
                proxy.scrollTo(last, anchor: .bottom)
            }
        }
    }
    
    private var composer: some View {
        HStack(spacing: 12) {
            TextField("메시지를 입력하세요", text: $app.messageInput, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...3)
            
            Button(action: {
                Task {
                    await app.sendMessage()
                    await app.fetchMessages()
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .imageScale(.medium)
                    .padding(.horizontal)
            }
            .buttonStyle(.borderedProminent)
            .disabled(app.messageInput.isEmpty)
        }
        .padding()
    }
}


// MARK: Preview
#if DEBUG
import SwiftUI

extension ChatApp {
    static func preview() -> ChatApp {
        let app = ChatApp()
        app.credential = Credential(email: "preview@sample.com", password: "password")
        // Seed a few sample messages
        let baseDate = Date()
        let samples: [Message] = [
            Message(senderEmail: "alice@example.com", content: "안녕하세요!", createdAt: baseDate.addingTimeInterval(-3600)),
            Message(senderEmail: "bob@example.com", content: "반가워요 :)", createdAt: baseDate.addingTimeInterval(-1800)),
            Message(senderEmail: "preview@sample.com", content: "테스트 메시지입니다.", createdAt: baseDate.addingTimeInterval(-300))
        ]
        
        app.messages = Set(samples)
        
        return app
    }
}
#endif

#Preview("ChatRoomView - Sample") {
    ChatRoomView(app: .preview())
}
