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
                        .padding(.bottom, 100) // Extra space for floating button
                    }
                }
                
                // Floating + button for creating new message/event
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            // TODO: Action to create new message or event
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                                .frame(width: 56, height: 56)
                        }
                        .floatingGlassButton()
                        .buttonStyle(.plain)
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
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
        .maximumGlassEffect()
        .padding(.horizontal, 20)
    }
}

