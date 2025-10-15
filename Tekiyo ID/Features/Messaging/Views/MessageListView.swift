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
                            
                            // Messages Section Header with + button
                            messagesSectionHeader
                            
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
        Picker("", selection: $viewModel.selectedSegment) {
            ForEach(MessageSegment.allCases, id: \.self) { segment in
                Text(segment.rawValue).tag(segment)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 20)
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
    
    private var messagesSectionHeader: some View {
        HStack {
            Text("Messages")
                .font(.custom("SF Pro Display", size: 17))
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
            
            // + Button with liquid glass
            Button(action: {
                // Action pour créer un nouveau message
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                    )
            }
            .buttonStyle(.plain)
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

