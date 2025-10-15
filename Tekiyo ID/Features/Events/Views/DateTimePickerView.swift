import SwiftUI

struct DateTimePickerView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var hasEndTime: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Date de début
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date de début")
                        .font(.custom("SF Pro Display", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    DatePicker("", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                }
                
                // Date de fin (optionnelle)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Date de fin")
                            .font(.custom("SF Pro Display", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Toggle("", isOn: $hasEndTime)
                    }
                    
                    if hasEndTime {
                        DatePicker("", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle("Date & Heure")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Valider") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
