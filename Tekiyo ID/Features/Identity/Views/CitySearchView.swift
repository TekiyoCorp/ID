import SwiftUI
import MapKit

struct CitySearchView: View {
    @Binding var selectedCity: String
    @Binding var isPresented: Bool
    
    @State private var searchText = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 46.603354, longitude: 1.888334), // Centre de la France
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
    )
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedLocation: MKMapItem?
    @State private var isSearching = false
    @State private var showResultsList = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Map interactive
                Map(coordinateRegion: $region, annotationItems: annotations) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        VStack(spacing: 0) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(selectedLocation == item.mapItem ? .green : .blue)
                                .background(
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 20, height: 20)
                                )
                            
                            if selectedLocation == item.mapItem {
                                Text(item.mapItem.name ?? "")
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
                        .onTapGesture {
                            selectLocation(item.mapItem)
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
                                ForEach(searchResults, id: \.self) { mapItem in
                                    CitySearchResultRow(
                                        mapItem: mapItem,
                                        isSelected: selectedLocation == mapItem,
                                        onSelect: {
                                            selectLocation(mapItem)
                                            centerMapOnLocation(mapItem)
                                            showResultsList = false
                                        }
                                    )
                                    
                                    if mapItem != searchResults.last {
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
                            if let city = selectedLocation?.placemark.locality ?? selectedLocation?.name {
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
    
    private var annotations: [MapAnnotationItem] {
        searchResults.map { MapAnnotationItem(mapItem: $0) }
    }
    
    private func selectLocation(_ mapItem: MKMapItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedLocation = mapItem
        }
    }
    
    private func centerMapOnLocation(_ mapItem: MKMapItem) {
        withAnimation {
            region = MKCoordinateRegion(
                center: mapItem.placemark.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
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
                    let cityResults = response.mapItems.filter { mapItem in
                        mapItem.placemark.locality != nil
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
struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let mapItem: MKMapItem
    
    var coordinate: CLLocationCoordinate2D {
        mapItem.placemark.coordinate
    }
}

// MARK: - City Search Result Row
struct CitySearchResultRow: View {
    let mapItem: MKMapItem
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
                    Text(mapItem.placemark.locality ?? mapItem.name ?? "Ville inconnue")
                        .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? .green : .primary)
                    
                    if let country = mapItem.placemark.country {
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
