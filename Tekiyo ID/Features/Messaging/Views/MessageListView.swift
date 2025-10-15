import SwiftUI

struct MessageListView: View {
    @StateObject private var viewModel = MessageListViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "111111")
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Segmented Control
                    segmentedControl
                        .padding(.top, 16)
                        .padding(.horizontal, 20)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            // Events Section
                            eventsSection
                                .padding(.top, 20)
                            
                            // Conversations List
                            VStack(spacing: 0) {
                                ForEach(viewModel.filteredConversations) { conversation in
                                    NavigationLink(destination: ChatView(conversation: conversation)) {
                                        ConversationRow(conversation: conversation)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var segmentedControl: some View {
        HStack(spacing: 0) {
            ForEach(MessageSegment.allCases, id: \.self) { segment in
                Button(action: { viewModel.selectedSegment = segment }) {
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Text(segment.rawValue)
                                .font(.custom("SF Pro Display", size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(viewModel.selectedSegment == segment ? .white.opacity(0.9) : .white.opacity(0.5))
                            
                            if segment == .messages && viewModel.selectedSegment == segment {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: geometry.size.width / 2)
                    .offset(x: viewModel.selectedSegment == .messages ? 0 : geometry.size.width / 2)
                    .animation(.spring(response: 0.3), value: viewModel.selectedSegment)
            }
        )
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var eventsSection: some View {
        HStack {
            Text("Événements")
                .font(.custom("SF Pro Display", size: 17))
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
            
            Text("\(viewModel.eventsCount)")
                .font(.custom("SF Pro Display", size: 15))
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.2))
                )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .padding(.horizontal, 20)
    }
}

