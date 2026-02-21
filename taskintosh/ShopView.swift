//
//  ShopView.swift
//  ta skintosh
//
//  Created by Ryan Mangeno on 2/20/26.
//


import SwiftUI

struct ShopView: View {
    @EnvironmentObject var store: AppStore
    @State private var showAddItem = false

    var body: some View {
        VStack(spacing: 0) {
            // Balance header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your Balance")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "#555555"))
                    HStack(spacing: 5) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.blue)
                        Text("\(store.totalPoints) points")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                Spacer()
                Button {
                    showAddItem = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color(hex: "#1E1E1E"))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(store.shopItems) { item in
                        ShopItemCard(item: item)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 18)
            }
        }
        .sheet(isPresented: $showAddItem) {
            AddShopItemSheet()
                .environmentObject(store)
        }
    }
}

struct ShopItemCard: View {
    @EnvironmentObject var store: AppStore
    let item: ShopItem
    @State private var isHovering = false
    @State private var showConfirm = false
    @State private var showBoughtAnimation = false

    var canAfford: Bool { store.totalPoints >= item.cost }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: item.icon)
                    .font(.system(size: 20))
                    .foregroundColor(item.isPurchased ? Color(hex: "#444444") : Color(hex: "#0088cc"))
                    .frame(width: 40, height: 40)
                    .background(Color(hex: item.isPurchased ? "#1A1A1A" : "#444444"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Spacer()

                if item.isPurchased {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#00D4AA"))
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(item.isPurchased ? Color(hex: "#444444") : .white)
                    .lineLimit(1)

                Text(item.description)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "#444444"))
                    .lineLimit(2)
            }

            // Cost + buy button
            HStack {
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundColor(canAfford && !item.isPurchased ? Color(hex: "#F5A623") : Color(hex: "#444444"))
                    Text("\(item.cost)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(canAfford && !item.isPurchased ? Color(hex: "#F5A623") : Color(hex: "#444444"))
                }

                Spacer()

                if !item.isPurchased {
                    Button {
                        if canAfford {
                            withAnimation(.spring(response: 0.3)) {
                                showBoughtAnimation = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                store.purchaseItem(item)
                                showBoughtAnimation = false
                            }
                        }
                    } label: {
                        Text(canAfford ? "Redeem" : "Need more")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(canAfford ? .black : Color(hex: "#444444"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(canAfford ? Color(hex: "#F5A623") : Color(hex: "#1E1E1E"))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(showBoughtAnimation ? 0.9 : 1.0)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: isHovering ? "#242424" : "#1C1C1C"))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(item.isPurchased ? Color(hex: "#222222") : Color(hex: "#00D4AA").opacity(isHovering && canAfford ? 0.4 : 0), lineWidth: 1)
                )
        )
        .onHover { isHovering = $0 }
        .contextMenu {
            Button("Delete Reward", role: .destructive) {
                store.deleteShopItem(item)
            }
        }
    }
}

// MARK: - Add Shop Item

struct AddShopItemSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var cost = 100
    @State private var icon = "gift.fill"

    let costPresets = [50, 100, 200, 500, 1000]
    let icons = ["gift.fill", "cup.and.saucer.fill", "tv.fill", "gamecontroller.fill", "sun.max.fill",
                 "cart.fill", "airplane", "music.note", "book.fill", "star.fill",
                 "figure.walk", "camera.fill", "heart.fill", "film.fill", "leaf.fill"]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Add Reward")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#555555"))
                        .frame(width: 28, height: 28)
                        .background(Color(hex: "#1E1E1E"))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(20)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("REWARD NAME").sectionLabel()
                        TextField("e.g. Coffee Break", text: $name)
                            .styledField()
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DESCRIPTION").sectionLabel()
                        TextField("A short description...", text: $description)
                            .styledField()
                    }

                    // Cost
                    VStack(alignment: .leading, spacing: 8) {
                        Text("POINT COST").sectionLabel()
                        HStack(spacing: 6) {
                            ForEach(costPresets, id: \.self) { preset in
                                Button {
                                    cost = preset
                                } label: {
                                    Text("\(preset)")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundColor(cost == preset ? .white : Color(hex: "#666666"))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 7)
                                        .background(RoundedRectangle(cornerRadius: 8).fill(cost == preset ? Color(hex: "#0088cc") : Color(hex: "#1A1A1A")))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Icon
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ICON").sectionLabel()
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                            ForEach(icons, id: \.self) { i in
                                Button {
                                    icon = i
                                } label: {
                                    Image(systemName: i)
                                        .font(.system(size: 16))
                                        .foregroundColor(icon == i ? .white : Color(hex: "#555555"))
                                        .frame(width: 44, height: 44)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(icon == i ? Color(hex: "#251E10") : Color(hex: "#1A1A1A"))
                                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(icon == i ? Color(hex: "#0088cc") : Color.clear, lineWidth: 1))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            Button {
                guard !name.isEmpty else { return }
                store.addShopItem(ShopItem(name: name, cost: cost, icon: icon, description: description))
                dismiss()
            } label: {
                Text("Add Reward")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(name.isEmpty ? Color(hex: "#444444") : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(name.isEmpty ? Color(hex: "#1E1E1E") : Color(hex: "#0088cc"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(name.isEmpty)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(.clear)
        .frame(width: 360)
    }
}

// MARK: - View Modifiers

extension Text {
    func sectionLabel() -> some View {
        self
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundColor(Color(hex: "#555555"))
            .kerning(1)
    }
}

extension TextField {
    func styledField() -> some View {
        self
            .textFieldStyle(.plain)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(.white)
            .padding(12)
            .background(Color(hex: "#1A1A1A"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#2A2A2A"), lineWidth: 1))
    }
}
