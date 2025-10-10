import SwiftUI
import MapKit

struct CitySearchView: View {
    @Binding var selectedCity: String
    @Binding var isPresented: Bool
    
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Liquid Glass Search Bar
                    LiquidGlassSearchBar(searchText: $searchText)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    // Search Results
                    if isSearching {
                        ProgressView("Recherche...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if searchResults.isEmpty && !searchText.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("Aucun résultat trouvé")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text("Essayez avec un autre nom de ville")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if searchResults.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "map")
                                .font(.system(size: 48))
                                .foregroundColor(.blue.opacity(0.6))
                            
                            Text("Recherchez votre ville")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Tapez le nom de votre ville dans la barre de recherche")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // List of search results
                        List(searchResults, id: \.self) { mapItem in
                            CitySearchResultRow(
                                mapItem: mapItem,
                                onSelect: { cityName in
                                    selectedCity = cityName
                                    isPresented = false
                                }
                            )
                        }
                        .listStyle(PlainListStyle())
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                            .font(.system(size: 18, weight: .medium))
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Choisir une ville")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onChange(of: searchText) { _, newValue in
            performSearch(query: newValue)
        }
    }
    
    private func performSearch(query: String) {
        guard !query.isEmpty, query.count > 2 else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 46.0, longitude: 2.0), // Centre de la France
            span: MKCoordinateSpan(latitudeDelta: 10.0, longitudeDelta: 10.0)
        )
        
        // Filtrer pour les villes uniquement
        request.resultTypes = [.pointOfInterest]
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                isSearching = false
                
                if let response = response {
                    // Filtrer les résultats pour ne garder que les villes
                    let cityResults = response.mapItems.filter { mapItem in
                        let name = mapItem.name?.lowercased() ?? ""
                        let placemark = mapItem.placemark
                        
                        // Vérifier si c'est une ville (pas un POI spécifique)
                        return !name.contains("restaurant") &&
                               !name.contains("hotel") &&
                               !name.contains("pharmacie") &&
                               !name.contains("banque") &&
                               !name.contains("école") &&
                               !name.contains("école") &&
                               !name.contains("université") &&
                               placemark.locality != nil
                    }
                    
                    searchResults = Array(cityResults.prefix(20)) // Limiter à 20 résultats
                } else {
                    searchResults = []
                }
            }
        }
    }
}

// MARK: - City Search Result Row
struct CitySearchResultRow: View {
    let mapItem: MKMapItem
    let onSelect: (String) -> Void
    
    var body: some View {
        Button(action: {
            let cityName = mapItem.placemark.locality ?? mapItem.name ?? "Ville inconnue"
            onSelect(cityName)
        }) {
            HStack(spacing: 12) {
                Image(systemName: "location.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(mapItem.placemark.locality ?? mapItem.name ?? "Ville inconnue")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    if let country = mapItem.placemark.country {
                        Text(country)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Liquid Glass Search Bar
struct LiquidGlassSearchBar: View {
    @Binding var searchText: String
    @FocusState private var isSearching: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
            
            TextField("Rechercher une ville...", text: $searchText)
                .font(.system(size: 16, weight: .medium))
                .focused($isSearching)
                .submitLabel(.search)
                .onSubmit {
                    // La recherche se déclenche automatiquement via onChange
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    isSearching = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isSearching = true
            }
        }
    }
}

#Preview {
    CitySearchView(
        selectedCity: .constant("Paris"),
        isPresented: .constant(true)
    )
}
