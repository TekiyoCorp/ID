import Foundation

enum TransactionType {
    case credit
    case debit
}

struct Transaction: Identifiable, Equatable {
    let id: String
    let user: TransactionUser
    let amount: Double
    let type: TransactionType
    let timestamp: Date
    
    init(id: String = UUID().uuidString, user: TransactionUser, amount: Double, type: TransactionType, timestamp: Date) {
        self.id = id
        self.user = user
        self.amount = amount
        self.type = type
        self.timestamp = timestamp
    }
    
    var formattedAmount: String {
        let sign = type == .credit ? "+" : "-"
        return "\(sign)\(Int(amount))€"
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: timestamp)
    }
    
    var dateGrouping: String {
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(timestamp) {
            return "Aujourd'hui"
        } else if calendar.isDateInYesterday(timestamp) {
            return "Hier"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "fr_FR")
            formatter.dateFormat = "EEEE dd/MM"
            return formatter.string(from: timestamp).capitalized
        }
    }
}

