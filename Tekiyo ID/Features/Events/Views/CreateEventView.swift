import SwiftUI

struct CreateEventView: View {
    @StateObject private var viewModel = CreateEventViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "111111")
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header avec liquid glass
                    headerView
                    
                    // Content
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            switch viewModel.currentStep {
                            case 0:
                                basicInfoStep
                            case 1:
                                locationStep
                            case 2:
                                dateTimeStep
                            case 3:
                                imageStep
                            case 4:
                                settingsStep
                            default:
                                basicInfoStep
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }
                
                // Bottom navigation
                VStack {
                    Spacer()
                    bottomNavigationView
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .background(
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .ignoresSafeArea(edges: .bottom)
                        )
                }
            }
        }
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
        .sheet(isPresented: $viewModel.showPreview) {
            EventPreviewView(eventData: viewModel.eventData, onPublish: viewModel.publishEvent)
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                    )
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text("Créer un événement")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
            
            // Progress indicator
            HStack(spacing: 4) {
                ForEach(0..<5) { index in
                    Circle()
                        .fill(index <= viewModel.currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    private var basicInfoStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Informations de base")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.9))
            
            // Nom de l'événement
            VStack(alignment: .leading, spacing: 8) {
                Text("Nom de l'événement")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                TextField("Soirée Rooftop Paris", text: $viewModel.eventData.eventName)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(hex: "1D1D1D"))
                    )
                    .foregroundColor(.white.opacity(0.9))
            }
            
            // Catégorie
            VStack(alignment: .leading, spacing: 8) {
                Text("Catégorie")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(EventCategory.allCases) { category in
                        CategoryButton(
                            category: category,
                            isSelected: viewModel.eventData.category.id == category.id
                        ) {
                            viewModel.eventData.category = category
                        }
                    }
                }
            }
            
            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                VStack(alignment: .trailing, spacing: 4) {
                    TextField("Courte description de votre événement...", text: $viewModel.eventData.description, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(hex: "1D1D1D"))
                        )
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(3...6)
                    
                    Text("\(viewModel.eventData.description.count)/200")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var locationStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Lieu")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.9))
            
            // Localisation automatique
            Button(action: {
                viewModel.requestCurrentLocation()
                viewModel.eventData.useCurrentLocation = true
            }) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                    Text("Utiliser ma position")
                        .foregroundColor(.blue)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.blue.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            
            // Recherche d'adresse
            Button(action: {
                viewModel.showLocationSearch = true
            }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.6))
                    Text(viewModel.eventData.location?.address ?? "Rechercher une adresse...")
                        .foregroundColor(viewModel.eventData.location == nil ? .white.opacity(0.6) : .white.opacity(0.9))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(hex: "1D1D1D"))
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var dateTimeStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Date & Heure")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.9))
            
            // Date de début
            VStack(alignment: .leading, spacing: 8) {
                Text("Date de début")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                DatePicker("", selection: $viewModel.eventData.startDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .colorScheme(.dark)
                    .accentColor(.blue)
            }
            
            // Date de fin (optionnelle)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Date de fin")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Toggle("", isOn: $viewModel.eventData.hasEndTime)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                
                if viewModel.eventData.hasEndTime {
                    DatePicker("", selection: $viewModel.eventData.endDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .colorScheme(.dark)
                        .accentColor(.blue)
                }
            }
        }
    }
    
    private var imageStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Image de couverture")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.9))
            
            Button(action: {
                viewModel.showImagePicker = true
            }) {
                if let coverImage = viewModel.eventData.coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.4))
                        
                        Text("Ajouter une image")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Optionnel mais conseillé")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(hex: "1D1D1D"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [5]))
                            )
                    )
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    private var settingsStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Paramètres")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.9))
            
            // Accès
            VStack(alignment: .leading, spacing: 12) {
                Text("Accès")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                HStack {
                    Text("Public")
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Toggle("", isOn: $viewModel.eventData.isPublic)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                
                Text(viewModel.eventData.isPublic ? "Visible sur la map & le feed" : "Sur invitation uniquement")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Conditions d'accès
            VStack(alignment: .leading, spacing: 12) {
                Text("Conditions d'accès")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.seal")
                            .foregroundColor(.green)
                        Text("Profil vérifié requis")
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Toggle("", isOn: $viewModel.eventData.requiresVerifiedProfile)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                        Text("Trust score minimum")
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text("\(Int(viewModel.eventData.minimumTrustScore))/10")
                            .foregroundColor(.blue)
                    }
                    
                    Slider(value: $viewModel.eventData.minimumTrustScore, in: 0...10, step: 1)
                        .accentColor(.blue)
                }
            }
            
            // Places limitées
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Places limitées")
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Toggle("", isOn: $viewModel.eventData.hasCapacityLimit)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                
                if viewModel.eventData.hasCapacityLimit {
                    HStack {
                        Text("Maximum")
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        TextField("100", value: $viewModel.eventData.maxCapacity, format: .number)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color(hex: "1D1D1D"))
                            )
                            .foregroundColor(.white.opacity(0.9))
                            .frame(width: 80)
                    }
                }
            }
        }
    }
    
    private var bottomNavigationView: some View {
        HStack {
            if viewModel.currentStep > 0 {
                Button("Précédent") {
                    viewModel.previousStep()
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
            }
            
            Spacer()
            
            Button("Suivant") {
                if viewModel.currentStep == 4 {
                    viewModel.showPreview = true
                } else {
                    viewModel.nextStep()
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.blue)
            )
            .disabled(!canProceed)
            .opacity(canProceed ? 1 : 0.6)
        }
    }
    
    private var canProceed: Bool {
        switch viewModel.currentStep {
        case 0:
            return !viewModel.eventData.eventName.isEmpty && !viewModel.eventData.description.isEmpty
        case 1:
            return viewModel.eventData.location != nil
        case 2:
            return !viewModel.eventData.hasEndTime || viewModel.eventData.endDate > viewModel.eventData.startDate
        default:
            return true
        }
    }
}
