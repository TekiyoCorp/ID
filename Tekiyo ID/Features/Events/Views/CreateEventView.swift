import SwiftUI

struct CreateEventView: View {
    @StateObject private var viewModel = CreateEventViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // All sections in one scroll
                    basicInfoSection
                    locationSection
                    dateTimeSection
                    imageSection
                    settingsSection
                    
                    // Publish button at the bottom
                    publishButton
                        .padding(.top, 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .background(Color(hex: "111111").ignoresSafeArea(.all))
            .navigationTitle("Créer un événement")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
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
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Informations")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                // Nom de l'événement
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nom de l'événement")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    TextField("Soirée Rooftop Paris", text: $viewModel.eventData.eventName)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Catégorie
                VStack(alignment: .leading, spacing: 8) {
                    Text("Catégorie")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
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
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        TextField("Courte description de votre événement...", text: $viewModel.eventData.description, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                        
                        Text("\(viewModel.eventData.description.count)/200")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Lieu")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                // Localisation automatique
                Button(action: {
                    viewModel.requestCurrentLocation()
                    viewModel.eventData.useCurrentLocation = true
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.accentColor)
                        Text("Utiliser ma position")
                            .foregroundColor(.accentColor)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.accentColor.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
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
                            .foregroundColor(.secondary)
                        Text(viewModel.eventData.location?.address ?? "Rechercher une adresse...")
                            .foregroundColor(viewModel.eventData.location == nil ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(.systemGray6))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Date & Heure")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                // Date de début
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date de début")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    DatePicker("", selection: $viewModel.eventData.startDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                }
                
                // Date de fin (optionnelle)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Date de fin")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.eventData.hasEndTime)
                    }
                    
                    if viewModel.eventData.hasEndTime {
                        DatePicker("", selection: $viewModel.eventData.endDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                    }
                }
            }
        }
    }
    
    private var imageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Image de couverture")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Button(action: {
                viewModel.showImagePicker = true
            }) {
                if let coverImage = viewModel.eventData.coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("Ajouter une image")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Optionnel mais conseillé")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.secondary.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                            )
                    )
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Paramètres")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 20) {
                // Accès
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Accès")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Toggle("Public", isOn: $viewModel.eventData.isPublic)
                    }
                    
                    Text(viewModel.eventData.isPublic ? "Visible sur la map & le feed" : "Sur invitation uniquement")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Conditions d'accès
                VStack(alignment: .leading, spacing: 12) {
                    Text("Conditions d'accès")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.seal")
                                .foregroundColor(.green)
                            Text("Profil vérifié requis")
                                .foregroundColor(.primary)
                            Spacer()
                            Toggle("", isOn: $viewModel.eventData.requiresVerifiedProfile)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.yellow)
                                Text("Trust score minimum")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(Int(viewModel.eventData.minimumTrustScore))/10")
                                    .foregroundColor(.accentColor)
                            }
                            
                            Slider(value: $viewModel.eventData.minimumTrustScore, in: 0...10, step: 1)
                        }
                    }
                }
                
                // Places limitées
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Places limitées")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.eventData.hasCapacityLimit)
                    }
                    
                    if viewModel.eventData.hasCapacityLimit {
                        HStack {
                            Text("Maximum")
                                .foregroundColor(.primary)
                            Spacer()
                            TextField("100", value: $viewModel.eventData.maxCapacity, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                        }
                    }
                }
            }
        }
    }
    
    private var publishButton: some View {
        Button("Publier l'événement") {
            viewModel.showPreview = true
        }
        .foregroundColor(.white)
        .font(.headline)
        .fontWeight(.semibold)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.accentColor)
        )
        .disabled(!viewModel.eventData.isValid)
        .opacity(viewModel.eventData.isValid ? 1 : 0.6)
    }
}
