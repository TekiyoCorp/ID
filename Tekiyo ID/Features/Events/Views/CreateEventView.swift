import SwiftUI

struct CreateEventView: View {
    @StateObject private var viewModel = CreateEventViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "111111")
                .ignoresSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header with close button
                    headerView
                    
                    // Background image section
                    backgroundImageSection
                    
                    // Event details card
                    eventDetailsCard
                    
                    // Organizer and description card
                    organizerDescriptionCard
                    
                    // Settings section
                    settingsSection
                    
                    // Publish button
                    publishButton
                        .padding(.top, 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showImagePicker) {
            EventImagePicker(selectedImage: $viewModel.eventData.coverImage)
        }
        .sheet(isPresented: $viewModel.showLocationSearch) {
            LocationSearchView(
                searchResults: $viewModel.searchResults,
                onSearch: viewModel.searchLocation,
                onSelect: viewModel.selectLocation
            )
        }
        .sheet(isPresented: $viewModel.showDateTimePicker) {
            DateTimePickerView(
                startDate: $viewModel.eventData.startDate,
                endDate: $viewModel.eventData.endDate,
                hasEndTime: $viewModel.eventData.hasEndTime
            )
        }
        .sheet(isPresented: $viewModel.showPreview) {
            EventPreviewView(eventData: viewModel.eventData, onPublish: viewModel.publishEvent)
        }
    }
    
    private var headerView: some View {
        HStack {
            // Close button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 44, height: 44)
            }
            .floatingGlassButton()
            .buttonStyle(.plain)
            
            Spacer()
            
            // Preview button
            Button(action: {
                viewModel.showPreview = true
            }) {
                Text("Aperçu")
                    .font(.custom("SF Pro Display", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .maximumGlassEffect()
            .buttonStyle(.plain)
        }
    }
    
    private var backgroundImageSection: some View {
        VStack(spacing: 16) {
            // Background image button
            Button(action: {
                viewModel.showImagePicker = true
            }) {
                if let coverImage = viewModel.eventData.coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    Circle()
                        .fill(Color(hex: "1D1D1D"))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.6))
                        )
                }
            }
            .buttonStyle(.plain)
            
            // Add background button
            Button(action: {
                viewModel.showImagePicker = true
            }) {
                Text("Ajouter un arrière-plan")
                    .font(.custom("SF Pro Display", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .maximumGlassEffect()
            .buttonStyle(.plain)
        }
    }
    
    private var eventDetailsCard: some View {
        VStack(spacing: 20) {
            // Event title
            VStack(alignment: .leading, spacing: 8) {
                TextField("Titre de l'événement", text: $viewModel.eventData.eventName)
                    .font(.custom("SF Pro Display", size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.9))
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            
            // Date and time
            Button(action: {
                viewModel.showDateTimePicker = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(formatDateTime(viewModel.eventData.startDate, viewModel.eventData.hasEndTime ? viewModel.eventData.endDate : nil))
                        .font(.custom("SF Pro Display", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            
            // Location
            Button(action: {
                viewModel.showLocationSearch = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "location")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(viewModel.eventData.location?.address ?? "Lieu")
                        .font(.custom("SF Pro Display", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .glassCard()
    }
    
    private var organizerDescriptionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Organizer
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    )
                
                Text("Organisé par Marie Dupont")
                    .font(.custom("SF Pro Display", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
            }
            
            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.custom("SF Pro Display", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
                
                TextField("Ajoutez une description.", text: $viewModel.eventData.description, axis: .vertical)
                    .font(.custom("SF Pro Display", size: 16))
                    .fontWeight(.regular)
                    .foregroundColor(.white.opacity(0.8))
                    .textFieldStyle(.plain)
                    .lineLimit(3...6)
            }
        }
        .padding(24)
        .glassCard()
    }
    
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Paramètres")
                .font(.custom("SF Pro Display", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))
            
            VStack(spacing: 20) {
                // Accès
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Accès")
                            .font(.custom("SF Pro Display", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                        
                        Toggle("Public", isOn: $viewModel.eventData.isPublic)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    
                    Text(viewModel.eventData.isPublic ? "Visible sur la map & le feed" : "Sur invitation uniquement")
                        .font(.custom("SF Pro Display", size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                // Conditions d'accès
                VStack(alignment: .leading, spacing: 12) {
                    Text("Conditions d'accès")
                        .font(.custom("SF Pro Display", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                    
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.seal")
                                .foregroundColor(.green)
                            Text("Profil vérifié requis")
                                .font(.custom("SF Pro Display", size: 16))
                                .foregroundColor(.white.opacity(0.9))
                            Spacer()
                            Toggle("", isOn: $viewModel.eventData.requiresVerifiedProfile)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.yellow)
                                Text("Trust score minimum")
                                    .font(.custom("SF Pro Display", size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                Spacer()
                                Text("\(Int(viewModel.eventData.minimumTrustScore))/10")
                                    .font(.custom("SF Pro Display", size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                            }
                            
                            Slider(value: $viewModel.eventData.minimumTrustScore, in: 0...10, step: 1)
                                .accentColor(.blue)
                        }
                    }
                }
                
                // Places limitées
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Places limitées")
                            .font(.custom("SF Pro Display", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.eventData.hasCapacityLimit)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    
                    if viewModel.eventData.hasCapacityLimit {
                        HStack {
                            Text("Maximum")
                                .font(.custom("SF Pro Display", size: 16))
                                .foregroundColor(.white.opacity(0.9))
                            Spacer()
                            TextField("100", value: $viewModel.eventData.maxCapacity, format: .number)
                                .font(.custom("SF Pro Display", size: 16))
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                        }
                    }
                }
            }
        }
        .padding(24)
        .glassCard()
    }
    
    private var publishButton: some View {
        Button("Publier l'événement") {
            viewModel.showPreview = true
        }
        .font(.custom("SF Pro Display", size: 18))
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .maximumGlassEffect()
        .disabled(!viewModel.eventData.isValid)
        .opacity(viewModel.eventData.isValid ? 1 : 0.6)
    }
    
    private func formatDateTime(_ startDate: Date, _ endDate: Date?) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        
        if let endDate = endDate {
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            let startString = formatter.string(from: startDate)
            let endString = formatter.string(from: endDate)
            return "\(startString) - \(endString)"
        } else {
            formatter.dateFormat = "dd/MM/yyyy à HH:mm"
            return formatter.string(from: startDate)
        }
    }
}
