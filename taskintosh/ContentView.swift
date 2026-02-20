//
//  ContentView.swift
//  taskintosh
//
//  Created by Ryan Mangeno on 2/20/26.
//


import SwiftUI

enum AppTab: CaseIterable {
    case tasks, shop, points

    var label: String {
        switch self {
        case .tasks: return "Tasks"
        case .shop: return "Shop"
        case .points: return "Points"
        }
    }

    var icon: String {
        switch self {
        case .tasks: return "checkmark.square.fill"
        case .shop: return "bag.fill"
        case .points: return "star.fill"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedTab: AppTab = .tasks

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView(selectedTab: $selectedTab)

            // Content
            ZStack {
                switch selectedTab {
                case .tasks:
                    TasksView()
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
                case .shop:
                    ShopView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                case .points:
                    PointsView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedTab)
        }
        .frame(width: 380, height: 520)
    }
}

struct HeaderView: View {
    @EnvironmentObject var store: AppStore
    @Binding var selectedTab: AppTab

    var body: some View {
        VStack(spacing: 0) {
            // Points pill + title row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Taskintosh")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Level up your day")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Points badge
                HStack(spacing: 5) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.orange)
                    Text("\(store.totalPoints)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.thinMaterial)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.1), lineWidth: 0.5))
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // Tab bar
            HStack(spacing: 8) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    TabButton(tab: tab, isSelected: selectedTab == tab) {
                        withAnimation(.spring(response: 0.2)) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 12)

            Rectangle()
                .fill(.primary.opacity(0.05))
                .frame(height: 1)
        }
    }
}

struct TabButton: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(tab.label)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isSelected ? .black : Color(hex: "#555555"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color(hex: "#F5A623") : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25), value: isSelected)
    }
}
