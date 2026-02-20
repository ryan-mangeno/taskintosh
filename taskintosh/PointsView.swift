//
//  PointsView.swift
//  taskintosh
//
//  Created by Ryan Mangeno on 2/20/26.
//


import SwiftUI

struct PointsView: View {
    @EnvironmentObject var store: AppStore

    var totalEarned: Int {
        store.transactions.filter { $0.type == .earned }.reduce(0) { $0 + $1.amount }
    }

    var totalSpent: Int {
        store.transactions.filter { $0.type == .spent }.reduce(0) { $0 + abs($1.amount) }
    }

    var completedTasksCount: Int {
        store.tasks.filter(\.isCompleted).count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Stats row
                HStack(spacing: 10) {
                    StatCard(label: "Balance", value: "\(store.totalPoints)", icon: "star.fill", color: Color(hex: "#F5A623"))
                    StatCard(label: "Earned", value: "\(totalEarned)", icon: "arrow.up.circle.fill", color: Color(hex: "#00D4AA"))
                    StatCard(label: "Spent", value: "\(totalSpent)", icon: "arrow.down.circle.fill", color: Color(hex: "#E85D75"))
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)

                // Progress ring
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(Color(hex: "#1E1E1E"), lineWidth: 10)
                            .frame(width: 90, height: 90)

                        let total = store.tasks.count
                        let completed = completedTasksCount
                        let progress: Double = total > 0 ? Double(completed) / Double(total) : 0

                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "#F5A623"), Color(hex: "#00D4AA")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .frame(width: 90, height: 90)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 0.6), value: progress)

                        VStack(spacing: 1) {
                            Text("\(completedTasksCount)")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("done")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color(hex: "#555555"))
                        }
                    }

                    Text("\(store.tasks.count) total tasks")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "#444444"))
                }

                // Recent transactions
                VStack(alignment: .leading, spacing: 10) {
                    Text("RECENT ACTIVITY")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#444444"))
                        .kerning(1)
                        .padding(.horizontal, 18)

                    if store.transactions.isEmpty {
                        Text("No activity yet. Complete a task!")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#333333"))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                    } else {
                        LazyVStack(spacing: 6) {
                            ForEach(store.transactions.reversed().prefix(20)) { tx in
                                TransactionRow(transaction: tx)
                            }
                        }
                        .padding(.horizontal, 18)
                    }
                }

                Spacer(minLength: 16)
            }
        }
    }
}

struct StatCard: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color(hex: "#555555"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(hex: "#151515"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.15), lineWidth: 1))
    }
}

struct TransactionRow: View {
    let transaction: PointsTransaction

    var formattedDate: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d, h:mm a"
        return fmt.string(from: transaction.date)
    }

    var body: some View {
        HStack(spacing: 10) {
            // Type icon
            Image(systemName: transaction.type == .earned ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(transaction.type == .earned ? Color(hex: "#00D4AA") : Color(hex: "#E85D75"))

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.reason)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "#CCCCCC"))
                    .lineLimit(1)
                Text(formattedDate)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "#444444"))
            }

            Spacer()

            Text("\(transaction.type == .earned ? "+" : "")\(transaction.amount)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(transaction.type == .earned ? Color(hex: "#00D4AA") : Color(hex: "#E85D75"))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(hex: "#131313"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#1E1E1E"), lineWidth: 1))
    }
}
