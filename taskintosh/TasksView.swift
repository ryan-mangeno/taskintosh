//
//  TasksView.swift
//  taskintosh
//
//  Created by Ryan Mangeno on 2/19/26.
//


import SwiftUI


struct TasksView: View {
    @EnvironmentObject var store: AppStore
    @State private var showAddTask = false
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())

    var tasksForSelectedDate: [Task] {
        store.tasks.filter { task in
            Calendar.current.isDate(task.dueDate, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            WeekStripView(selectedDate: $selectedDate)
                .padding(.top, 12)
                .padding(.horizontal, 18)

            ScrollView {
                LazyVStack(spacing: 8) {
                    if tasksForSelectedDate.isEmpty {
                        EmptyDayView()
                            .padding(.top, 40)
                    } else {
                        ForEach(tasksForSelectedDate) { task in
                            TaskRowView(taskID: task.id)
                        }
                        .padding(.horizontal, 18)
                    }
                }
                .padding(.vertical, 12)
            }

            Button {
                showAddTask = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                    Text("Add Task")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(Color(hex: "#F5A623"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 18)
            .padding(.bottom, 14)
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskSheet(defaultDate: selectedDate)
                .environmentObject(store)
        }
    }
}

// MARK: - Week Strip

struct WeekStripView: View {
    @EnvironmentObject var store: AppStore
    @Binding var selectedDate: Date

    private let dayLetters = ["M", "T", "W", "T", "F", "S", "S"]
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 8) {
            // Week nav
            HStack {
                Button {
                    withAnimation { store.selectedWeekOffset -= 1 }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "#555555"))
                }
                .buttonStyle(.plain)

                Spacer()

                Text(weekLabel)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "#888888"))

                Spacer()

                Button {
                    withAnimation { store.selectedWeekOffset += 1 }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "#555555"))
                }
                .buttonStyle(.plain)
            }

            // Day pills
            HStack(spacing: 4) {
                ForEach(Array(store.currentWeekDates.enumerated()), id: \.offset) { i, date in
                    DayPill(
                        letter: dayLetters[i],
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDateInToday(date),
                        taskCount: store.tasks(for: date).count,
                        completedCount: store.tasks(for: date).filter(\.isCompleted).count
                    ) {
                        withAnimation(.spring(response: 0.25)) {
                            selectedDate = date
                        }
                    }
                }
            }
        }
    }

    var weekLabel: String {
        let dates = store.currentWeekDates
        guard let first = dates.first, let last = dates.last else { return "" }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        return "\(fmt.string(from: first)) – \(fmt.string(from: last))"
    }
}

struct DayPill: View {
    let letter: String
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let taskCount: Int
    let completedCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(letter)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isSelected ? .black : Color(hex: "#555555"))

                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .black : isToday ? Color(hex: "#F5A623") : .white)

                // Dot indicator
                Circle()
                    .fill(taskCount > 0 ? (completedCount == taskCount ? Color(hex: "#00D4AA") : Color(hex: "#F5A623")) : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color(hex: "#F5A623") : Color(hex: "#1A1A1A"))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Task Row

struct TaskRowView: View {
    let taskID: UUID
    @EnvironmentObject var store: AppStore
    @State private var isHovering = false

    var task: Task? {
        store.tasks.first { $0.id == taskID }
    }

    var body: some View {
        if let task {
            HStack(spacing: 12) {
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(task.category.color)
                        .frame(width: 3)
                }

                Button {
                    withAnimation(.spring(response: 0.25)) {
                        if task.isCompleted {
                            store.uncompleteTask(task)
                        } else {
                            store.completeTask(task)
                        }
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(
                                task.isCompleted ? task.category.color : Color(hex: "#333333"),
                                lineWidth: 1.5
                            )
                            .frame(width: 22, height: 22)

                        if task.isCompleted {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(task.category.color)
                                    .frame(width: 22, height: 22)

                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .scaleEffect(0.85)
                            .transition(.scale)
                        }
                    }
                    .animation(.easeInOut(duration: 0.15), value: task.isCompleted)
                }
                .buttonStyle(.borderless)

                VStack(alignment: .leading, spacing: 3) {
                    Text(task.title)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(task.isCompleted ? Color(hex: "#444444") : .white)
                        .strikethrough(task.isCompleted, color: Color(hex: "#444444"))

                    HStack(spacing: 8) {
                        Label(task.category.rawValue, systemImage: task.category.icon)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(task.category.color.opacity(0.8))

                        if task.recurrence != .none {
                            Label(task.recurrence.rawValue, systemImage: "arrow.clockwise")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(hex: "#555555"))
                        }
                    }
                }

                Spacer()

                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundColor(task.isCompleted ? Color(hex: "#444444") : Color(hex: "#F5A623"))
                    Text("\(task.points)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(task.isCompleted ? Color(hex: "#444444") : Color(hex: "#F5A623"))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: "#1E1E1E"))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: isHovering ? "#1E1E1E" : "#161616"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#222222"), lineWidth: 1)
                    )
            )
            .onHover { isHovering = $0 }
            .contextMenu {
                Button("Delete Task", role: .destructive) {
                    store.deleteTask(task)
                }
            }
        }
    }
}
// MARK: - Empty State

struct EmptyDayView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 32))
                .foregroundColor(Color(hex: "#2A2A2A"))
            Text("No tasks today")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Color(hex: "#3A3A3A"))
            Text("Add a task to start earning points")
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "#2E2E2E"))
        }
    }
}
