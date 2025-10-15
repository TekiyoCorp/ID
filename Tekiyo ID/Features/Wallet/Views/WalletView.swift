import SwiftUI

struct WalletView: View {
    @StateObject private var viewModel = WalletViewModel()
    
    var body: some View {
        ZStack {
            Color(hex: "111111")
                .ignoresSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header with balance
                    balanceHeader
                        .padding(.top, 20)
                    
                    // Action buttons
                    WalletActionButtons(
                        onSend: viewModel.onSend,
                        onReceive: viewModel.onReceive,
                        onAdd: viewModel.onAdd
                    )
                    .padding(.horizontal, 20)
                    
                    // History section
                    historySection
                        .padding(.top, 12)
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    private var balanceHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Total")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Text("\(viewModel.formattedBalance) €")
                .font(.system(size: 48, weight: .medium, design: .default))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .background(.ultraThinMaterial)
        )
        .padding(.horizontal, 20)
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Historique")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
            
            ForEach(viewModel.groupedTransactions, id: \.0) { dateGroup, transactions in
                VStack(alignment: .leading, spacing: 12) {
                    Text(dateGroup)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 8) {
                        ForEach(transactions) { transaction in
                            TransactionRow(transaction: transaction)
                                .padding(.horizontal, 20)
                        }
                    }
                }
            }
        }
    }
}

