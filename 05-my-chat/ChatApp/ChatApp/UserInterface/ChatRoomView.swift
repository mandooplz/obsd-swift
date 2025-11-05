//
//  ChatRoomView.swift
//  ChatApp
//
//  Created by 김민우 on 11/5/25.
//

import SwiftUI
import Observation


// MARK: UserInterface
struct ChatRoomView: View {
    @Bindable var app: ChatApp
    @State private var draftMessage: String = ""
    @State private var isSending: Bool = false
    
    private var isSendButtonDisabled: Bool {
        isSending || draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
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
            await app.subscribeServer()
        }
        .onAppear {
            Task { await app.fetchMessages() }
        }
    }
    
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
        List(app.messageTimeline, id: \.id) { message in
            MessageRowView(message: message)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .refreshable {
            await app.fetchMessages()
        }
    }
    
    private var composer: some View {
        HStack(spacing: 12) {
            TextField("메시지를 입력하세요", text: $draftMessage, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...3)
            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .imageScale(.medium)
                    .padding(10)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isSendButtonDisabled)
        }
        .padding()
    }
    
    private func sendMessage() {
        let content = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard content.isEmpty == false else { return }
        draftMessage = ""
        Task { @MainActor in
            guard isSending == false else { return }
            isSending = true
            defer { isSending = false }
            await app.sendMessage(content: content)
        }
    }
}
