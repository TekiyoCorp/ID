import SwiftUI

struct EventsListView: View {
    @StateObject private var viewModel = EventsViewModel()
    
    var body: some View {
        ZStack {
            Color(hex: "111111")
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.top, 8)
                
                // Events List
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(viewModel.events) { event in
                            EventCard(event: event) {
                                viewModel.selectEvent(event)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 100) // Extra space for floating button
                }
            }
            
            // Floating Create Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    CreateEventFloatingButton {
                        viewModel.showCreateEvent = true
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $viewModel.showEventDetail) {
            if let event = viewModel.selectedEvent {
                EventDetailModal(
                    event: event,
                    onRegister: {
                        viewModel.registerForEvent(event.id)
                    },
                    onDismiss: {
                        viewModel.showEventDetail = false
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $viewModel.showCreateEvent) {
            CreateEventView()
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 16) {
            // Left: Profile icon
            Button(action: {}) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
            }
            .buttonStyle(.plain)
            
            // Center: Events pill
            HStack(spacing: 8) {
                Text("Mes événements")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                
                Circle()
                    .fill(Color.blue)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Text("1")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.1))
            )
            
            Spacer()
            
            // Right: Search icon
            Button(action: {}) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}
