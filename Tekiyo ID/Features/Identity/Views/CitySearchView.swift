import SwiftUI
import MapKit

struct CitySearchView: View {
    @Binding var selectedCity: String
    @Binding var isPresented: Bool
    
    private static let defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 46.603354, longitude: 1.888334),
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
    )
    
    @State private var searchText = ""
    @State private var cameraPosition: MapCameraPosition = .region(Self.defaultRegion)
    @State private var searchResults: [CitySearchResult] = []
    @State private var selectedLocation: CitySearchResult?
    @State private var isSearching = false
    @State private var showResultsList = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Map interactive
                Map(position: $cameraPosition, interactionModes: [.all]) {
                    ForEach(annotations) { item in
                        Annotation(item.displayName, coordinate: item.coordinate) {
                            CityAnnotationPin(
                                result: item,
                                isSelected: selectedLocation?.id == item.id,
                                onTap: { selectLocation(item) }
                            )
                        }
                    }
                }
                .ignoresSafeArea()
                
                // Liquid Glass Search Bar
                VStack(spacing: 0) {
                    LiquidGlassSearchBar(searchText: $searchText)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    // Liste déroulante des résultats
                    if showResultsList && !searchResults.isEmpty {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(searchResults) { result in
                                    CitySearchResultRow(
                                        result: result,
                                        isSelected: selectedLocation?.id == result.id,
                                        onSelect: {
                                            selectLocation(result)
                                            centerMapOnLocation(result)
                                            showResultsList = false
                                        }
                                    )
                                    
                                    if result.id != searchResults.last?.id {
                                        Divider()
                                            .padding(.leading, 48)
                                    }
                                }
                            }
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .frame(maxHeight: 300)
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                
                // Bouton de validation (sticky en bas)
                if selectedLocation != nil {
                    VStack {
                        Spacer()
                        
                        Button(action: {
                            if let city = selectedLocation?.city {
                                selectedCity = city
                                isPresented = false
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                
                                Text("Valider")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.blue)
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
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
    
    private var annotations: [CitySearchResult] {
        searchResults
    }
    
    private func selectLocation(_ result: CitySearchResult) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedLocation = result
        }
    }
    
    private func centerMapOnLocation(_ result: CitySearchResult) {
        withAnimation {
            let newRegion = MKCoordinateRegion(
                center: result.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
            cameraPosition = .region(newRegion)
        }
    }
    
    private func performSearch(query: String) {
        guard !query.isEmpty, query.count > 2 else {
            searchResults = []
            isSearching = false
            showResultsList = false
            return
        }
        
        isSearching = true
        showResultsList = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = [.address]
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                isSearching = false
                
                if let response = response {
                    // Filtrer pour ne garder que les villes
                    let cityResults = response.mapItems.compactMap { mapItem -> CitySearchResult? in
                        CitySearchResult(mapItem: mapItem)
                    }
                    
                    searchResults = Array(cityResults.prefix(10))
                } else {
                    searchResults = []
                }
            }
        }
    }
}

// MARK: - Map Annotation Item
// MARK: - City Search Result Row
struct CitySearchResultRow: View {
    let result: CitySearchResult
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "location.fill")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? .green : .blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.displayName)
                        .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? .green : .primary)
                    
                    if let country = result.country {
                        Text(country)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color.green.opacity(0.1) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct CityAnnotationPin: View {
    let result: CitySearchResult
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(isSelected ? .green : .blue)
                .background(
                    Circle()
                        .fill(.white)
                        .frame(width: 20, height: 20)
                )
            
            if isSelected {
                Text(result.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.green)
                    )
                    .offset(y: 4)
            }
        }
        .onTapGesture(perform: onTap)
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
