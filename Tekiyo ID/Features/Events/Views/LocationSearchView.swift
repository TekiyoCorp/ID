import SwiftUI

struct LocationSearchView: View {
    @Binding var searchResults: [String]
    let onSearch: (String) -> Void
    let onSelect: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.6))
                    
                    TextField("Rechercher une adresse...", text: $searchText)
                        .textFieldStyle(.plain)
                        .foregroundColor(.white.opacity(0.9))
                        .onChange(of: searchText) { newValue in
                            onSearch(newValue)
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                        .fill(Color(hex: "1D1D1D"))
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Results
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(searchResults, id: \.self) { result in
                            Button(action: {
                                onSelect(result)
                            }) {
                                HStack {
                                    Image(systemName: "location")
                                        .foregroundColor(.blue)
                                    
                                    Text(result)
                                        .foregroundColor(.white.opacity(0.9))
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                                        .fill(Color(hex: "1D1D1D"))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
                
                Spacer()
            }
            .background(Color(hex: "111111").ignoresSafeArea(.all))
            .navigationTitle("Lieu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}
