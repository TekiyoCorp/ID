import SwiftUI

struct ChatView: View {
    let conversation: Conversation
    @StateObject private var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(conversation: Conversation) {
        self.conversation = conversation
        self._viewModel = StateObject(wrappedValue: ChatViewModel(conversationUser: conversation.user))
    }
    
    var body: some View {
        ZStack {
            Color(hex: "111111")
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                header
                    .padding(.top, 8)
                
                // Messages
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Transaction bubble
                        if viewModel.showTransactionBubble {
                            TransactionBubble(user: conversation.user)
                                .padding(.top, 20)
                        }
                        
                        // Messages
                        ForEach(viewModel.messages) { message in
                            MessageBubble(
                                message: message,
                                userAvatar: message.isFromCurrentUser ? nil : conversation.user
                            )
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                // Input field
                inputField
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
        }
        .navigationBarHidden(true)
    }
    
    private var header: some View {
        HStack(spacing: 16) {
            // Back button
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            
            // Avatar
            Circle()
                .fill(conversation.user.avatarColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: conversation.user.avatarImage)
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.9))
                )
            
            // Name and status
            VStack(alignment: .leading, spacing: 2) {
                Text(conversation.user.name)
                    .font(.custom("SF Pro Display", size: 17))
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
                
                Text("En ligne")
                    .font(.custom("SF Pro Display", size: 13))
                    .fontWeight(.regular)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
    
    private var inputField: some View {
        HStack(spacing: 12) {
            // Plus button
            Button(action: {}) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.secondary)
            }
            
            // Text field
            HStack {
                TextField("Tapez votre message", text: $viewModel.messageText)
                    .textFieldStyle(.plain)
                
                if !viewModel.messageText.isEmpty {
                    Button(action: { viewModel.sendMessage() }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                    }
                } else {
                    Button(action: {}) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.systemGray6))
            )
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

