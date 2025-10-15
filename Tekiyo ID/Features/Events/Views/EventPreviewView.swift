import SwiftUI

struct EventPreviewView: View {
    let eventData: CreateEventData
    let onPublish: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Cover image
                    if let coverImage = eventData.coverImage {
                        Image(uiImage: coverImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Title & Category
                        HStack {
                            Text(eventData.eventName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text(eventData.category.emoji)
                                Text(eventData.category.name)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(eventData.category.color.opacity(0.2))
                            )
                        }
                        
                        // Description
                        Text(eventData.description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                        
                        // Location
                        if let location = eventData.location {
                            HStack {
                                Image(systemName: "location")
                                    .foregroundColor(.blue)
                                Text(location.address)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        // Date & Time
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.green)
                            Text(formatDate(eventData.startDate))
                                .foregroundColor(.white.opacity(0.8))
                            
                            if eventData.hasEndTime {
                                Text("→ \(formatDate(eventData.endDate))")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        
                        // Access settings
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: eventData.isPublic ? "globe" : "lock")
                                    .foregroundColor(eventData.isPublic ? .green : .orange)
                                Text(eventData.isPublic ? "Événement public" : "Événement privé")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            if eventData.requiresVerifiedProfile {
                                HStack {
                                    Image(systemName: "checkmark.seal")
                                        .foregroundColor(.green)
                                    Text("Profil vérifié requis")
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            
                            if eventData.minimumTrustScore > 0 {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.yellow)
                                    Text("Trust score minimum: \(Int(eventData.minimumTrustScore))/10")
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            
                            if eventData.hasCapacityLimit {
                                HStack {
                                    Image(systemName: "person.3")
                                        .foregroundColor(.blue)
                                    Text("Maximum \(eventData.maxCapacity) places")
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            .background(Color(hex: "111111").ignoresSafeArea(.all))
            .navigationTitle("Aperçu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Publier") {
                        onPublish()
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.blue)
                    )
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy à HH:mm"
        return formatter.string(from: date)
    }
}
