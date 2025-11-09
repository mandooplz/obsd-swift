//
//  MessageRowView.swift
//  ChatApp
//
//  Created by 김민우 on 11/5/25.
//

import SwiftUI
import MyChatValues


// MARK: UserInterface
struct MessageRowView: View {
    let message: Message
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 6) {
                header
                Text(message.content)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
            Spacer()
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(message.senderEmail)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(message.createdAt.formatted(date: .omitted, time: .shortened))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}


// MARK: Preview
#Preview(traits: .sizeThatFitsLayout){
    let message = Message(senderEmail: "user@example.com",
                          content: "안녕하세요! 처음이에요",
                          createdAt: .now)
    
    MessageRowView(message: message)
        .padding()
}
