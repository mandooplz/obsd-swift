//
//  MessageRowView.swift
//  ChatApp
//
//  Created by 김민우 on 11/5/25.
//

import SwiftUI


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
        .padding(.vertical, 6)
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


#Preview {
    MessageRowView(message: Message(senderEmail: "user@example.com", content: "안녕하세요!", createdAt: .now))
        .previewLayout(.sizeThatFits)
        .padding()
}
