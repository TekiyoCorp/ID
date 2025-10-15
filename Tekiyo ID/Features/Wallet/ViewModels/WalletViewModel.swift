import SwiftUI
import Combine

@MainActor
final class WalletViewModel: ObservableObject {
    @Published var balance: Double = 12754.84
    @Published var transactions: [Transaction] = []
    
    init() {
        loadMockTransactions()
    }
    
    private func loadMockTransactions() {
        let marieUser = TransactionUser(
            name: "Marie D.",
            avatarImage: "person.fill",
            avatarColor: Color(red: 0.4, green: 0.6, blue: 0.9)
        )
        
        let thomasUser = TransactionUser(
            name: "Thomas L.",
            avatarImage: "person.fill",
            avatarColor: Color.gray
        )
        
        let calendar = Calendar.current
        let now = Date()
        
        // Aujourd'hui
        let today1 = calendar.date(byAdding: .hour, value: -7, to: now)!
        let today2 = calendar.date(byAdding: .hour, value: -12, to: now)!
        
        // Hier
        let yesterday1 = calendar.date(byAdding: .day, value: -1, to: today1)!
        let yesterday2 = calendar.date(byAdding: .day, value: -1, to: today2)!
        
        // Jeudi 18/02
        let oldDate = calendar.date(byAdding: .day, value: -5, to: now)!
        
        transactions = [
            Transaction(user: marieUser, amount: 23, type: .credit, timestamp: today1),
            Transaction(user: thomasUser, amount: 74, type: .debit, timestamp: today2),
            Transaction(user: marieUser, amount: 23, type: .credit, timestamp: yesterday1),
            Transaction(user: thomasUser, amount: 74, type: .debit, timestamp: yesterday2),
            Transaction(user: marieUser, amount: 23, type: .credit, timestamp: oldDate)
        ]
    }
    
    var groupedTransactions: [(String, [Transaction])] {
        let grouped = Dictionary(grouping: transactions) { $0.dateGrouping }
        let sortedKeys = grouped.keys.sorted { key1, key2 in
            // Sort by: Aujourd'hui, Hier, then dates
            if key1 == "Aujourd'hui" { return true }
            if key2 == "Aujourd'hui" { return false }
            if key1 == "Hier" { return true }
            if key2 == "Hier" { return false }
            return key1 > key2
        }
        return sortedKeys.map { ($0, grouped[$0]!) }
    }
    
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: balance)) ?? "0.00"
    }
    
    func onSend() {
        // Action for send
    }
    
    func onReceive() {
        // Action for receive
    }
    
    func onAdd() {
        // Action for add
    }
}

