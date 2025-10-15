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
                    .font(.custom("SF Pro Display", size: 20))
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
            }
            
            Text("\(viewModel.formattedBalance) €")
                .font(.custom("SF Pro Display", size: 48))
                .fontWeight(.medium)
                .kerning(-2.88)
                .foregroundColor(.white.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Historique")
                .font(.custom("SF Pro Display", size: 22))
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 20)
            
            ForEach(viewModel.groupedTransactions, id: \.0) { dateGroup, transactions in
                VStack(alignment: .leading, spacing: 12) {
                    Text(dateGroup)
                        .font(.custom("SF Pro Display", size: 15))
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.6))
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

