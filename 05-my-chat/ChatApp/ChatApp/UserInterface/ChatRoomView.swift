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
        ScrollViewReader { proxy in
            List(app.sortedMessages, id: \.id) { message in
                MessageRowView(message: message)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .refreshable {
                await app.fetchMessages()
            }
            .onChange(of: app.sortedMessages) { ids in
                guard let last = ids.last else { return }
                withAnimation {
                    proxy.scrollTo(last, anchor: .bottom)
                }
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
    }}
