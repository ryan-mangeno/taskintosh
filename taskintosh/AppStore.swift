//
//  AppStore.swift
//  taskintosh
//
//  Created by Ryan Mangeno on 2/20/26.
//


import SwiftUI
import Combine

// MARK: - Models

struct Task: Identifiable, Codable {
    var id = UUID()
    let templateID: UUID? // nil is used for recurring tasks
    var title: String
    var points: Int
    var isCompleted: Bool = false
    var completedAt: Date?
    var dueDate: Date
    var category: TaskCategory
    var recurrence: Recurrence

    enum TaskCategory: String, Codable, CaseIterable {
        case work = "Work"
        case health = "Health"
        case personal = "Personal"
        case learning = "Learning"
        case creative = "Creative"

        var color: Color {
            switch self {
            case .work: return Color(hex: "#5E81F4")
            case .health: return Color(hex: "#00D4AA")
            case .personal: return Color(hex: "#F5A623")
            case .learning: return Color(hex: "#E85D75")
            case .creative: return Color(hex: "#A78BFA")
            }
        }

        var icon: String {
            switch self {
            case .work: return "briefcase.fill"
            case .health: return "heart.fill"
            case .personal: return "person.fill"
            case .learning: return "book.fill"
            case .creative: return "paintbrush.fill"
            }
        }
    }

    enum Recurrence: String, Codable, CaseIterable {
        case none = "Once"
        case daily = "Daily"
        case weekly = "Weekly"
        
        var intervalDays: Int {
            switch self {
                case .none:   return 0
                case .daily:  return 1
                case .weekly: return 7
            }
        }
    }

}

struct ShopItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var cost: Int
    var icon: String
    var description: String
    var isPurchased: Bool = false
    var purchasedAt: Date?
}

struct PointsTransaction: Identifiable, Codable {
    var id = UUID()
    var amount: Int
    var reason: String
    var date: Date
    var type: TransactionType

    enum TransactionType: String, Codable {
        case earned, spent
    }
}

// MARK: - AppStore

class AppStore: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var recurringTasks: [Task] = []
    @Published var shopItems: [ShopItem] = []
    @Published var transactions: [PointsTransaction] = []
    @Published var totalPoints: Int = 0
    @Published var selectedWeekOffset: Int = 0

    private let saveKey = "taskbar_data"

    init() {
        load()
        if shopItems.isEmpty { seedShop() }
    }
    
    func resetAllData() {
        tasks = []
        recurringTasks = []
        transactions = []
        totalPoints = 0
        save() 
    }

    // MARK: Week Navigation

    var currentWeekDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysToMonday = (weekday == 1 ? -6 : 2 - weekday)
        let monday = calendar.date(byAdding: .day, value: daysToMonday + (selectedWeekOffset * 7), to: today)!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    func tasks(for date: Date) -> [Task] {
        let calendar = Calendar.current
        return tasks.filter {
            calendar.isDate($0.dueDate, inSameDayAs: date)
        }
    }

    // MARK: - Task Actions

    func addTask(_ task: Task) {
        tasks.append(task)
        save()
    }
    
    func addRecurringTask(_ task: Task) {
        recurringTasks.append(task)
        save()
    }

    func completeTask(_ task: Task) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        if !tasks[idx].isCompleted {
            tasks[idx].isCompleted = true
            tasks[idx].completedAt = Date()
            totalPoints += task.points
            transactions.append(PointsTransaction(
                amount: task.points,
                reason: "Completed: \(task.title)",
                date: Date(),
                type: .earned
            ))
            save()
        }
    }

    func uncompleteTask(_ task: Task) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        if tasks[idx].isCompleted {
            totalPoints -= task.points
            tasks[idx].isCompleted = false
            tasks[idx].completedAt = nil
            transactions.append(PointsTransaction(
                amount: -task.points,
                reason: "Uncompleted: \(task.title)",
                date: Date(),
                type: .spent
            ))
            save()
        }
    }

    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        
        if let templateID = task.templateID {
            recurringTasks.removeAll { $0.id == templateID }
        }
        
        save()
    }
    

    // MARK: - Shop Actions

    func addShopItem(_ item: ShopItem) {
        shopItems.append(item)
        save()
    }

    func purchaseItem(_ item: ShopItem) {
        guard let idx = shopItems.firstIndex(where: { $0.id == item.id }),
              totalPoints >= item.cost else { return }

        totalPoints -= item.cost
        shopItems[idx].isPurchased = true
        shopItems[idx].purchasedAt = Date()
        transactions.append(PointsTransaction(
            amount: -item.cost,
            reason: "Purchased: \(item.name)",
            date: Date(),
            type: .spent
        ))
        save()
    }

    func deleteShopItem(_ item: ShopItem) {
        shopItems.removeAll { $0.id == item.id }
        save()
    }

    // MARK: - Persistence

    private struct SaveData: Codable {
        var tasks: [Task]
        var recurringTasks: [Task]
        var shopItems: [ShopItem]
        var transactions: [PointsTransaction]
        var totalPoints: Int
    }

    func save() {
        let data = SaveData(tasks: tasks, recurringTasks: recurringTasks, shopItems: shopItems, transactions: transactions, totalPoints: totalPoints)
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode(SaveData.self, from: data) else { return }
        tasks = decoded.tasks
        recurringTasks = decoded.recurringTasks
        shopItems = decoded.shopItems
        transactions = decoded.transactions
        totalPoints = decoded.totalPoints
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for template in recurringTasks {

            // compute day difference
            let dueDate = calendar.startOfDay(for: template.dueDate)
            let dayDifference = calendar.dateComponents([.day], from: dueDate, to: today).day ?? 0
            let interval = template.recurrence.intervalDays

            guard interval > 0, dayDifference >= 0, dayDifference % interval == 0 else {
                continue
            }

            // Check if todays task already exists
            let exists = tasks.contains(where: { t in
                t.templateID == template.id &&
                calendar.isDate(t.dueDate, inSameDayAs: today)
            })
            if exists { continue }

            // generate a new task instance for today
            let newTask = Task(
                id: UUID(),                   // new id for swiftui requirement
                templateID: template.id,      // track the template
                title: template.title,
                points: template.points,
                dueDate: today,             
                category: template.category,
                recurrence: template.recurrence
            )

            tasks.append(newTask)
        }
    }

    private func seedShop() {
        shopItems = [
            ShopItem(name: "Coffee Break", cost: 50, icon: "cup.and.saucer.fill", description: "Take a proper coffee break guilt-free"),
            ShopItem(name: "Episode Night", cost: 150, icon: "tv.fill", description: "Watch an episode of your fave show"),
            ShopItem(name: "Order Takeout", cost: 300, icon: "bag.fill", description: "Treat yourself to takeout"),
            ShopItem(name: "Game Session", cost: 200, icon: "gamecontroller.fill", description: "2 hours of gaming, no guilt"),
            ShopItem(name: "Day Off", cost: 500, icon: "sun.max.fill", description: "A completely free day"),
        ]
        save()
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

/*
#Preview {
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        
        AddTaskSheet(defaultDate: Date())
            .environmentObject(AppStore())
            .frame(width: 380, height: 450)
            .background(Color.white)
    }
}
*/
