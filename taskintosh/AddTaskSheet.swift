//
//  AddTaskSheet.swift
//  taskintosh
//
//  Created by Ryan Mangeno on 2/20/26.
//


import SwiftUI

struct AddTaskSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var defaultDate: Date

    @State private var title = ""
    @State private var points = 50
    @State private var category: Task.TaskCategory = .personal
    @State private var recurrence: Task.Recurrence = .none
    @State private var dueDate: Date

    init(defaultDate: Date) {
        self.defaultDate = defaultDate
        _dueDate = State(initialValue: defaultDate)
    }

    var pointsPresets = [10, 25, 50, 100, 200]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("New Task")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#555555"))
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Task Name", systemImage: "pencil")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(hex: "#666666"))

                        TextField("What do you need to do?", text: $title)
                            .textFieldStyle(.plain)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color(hex: "#1A1A1A"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#2A2A2A"), lineWidth: 1))
                    }

                    // Points
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Points Value", systemImage: "star.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(hex: "#666666"))

                        HStack(spacing: 8) {
                            ForEach(pointsPresets, id: \.self) { preset in
                                Button {
                                    withAnimation(.spring(response: 0.2)) { points = preset }
                                } label: {
                                    Text("\(preset)")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(points == preset ? .black : Color(hex: "#888888"))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(points == preset ? Color(hex: "#F5A623") : Color(hex: "#1A1A1A"))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // Custom points
                        HStack(spacing: 8) {
                            Text("Custom:")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "#555555"))
                            TextField("0", value: $points, format: .number)
                                .textFieldStyle(.plain)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#F5A623"))
                                .frame(width: 60)
                                .padding(8)
                                .background(Color(hex: "#1A1A1A"))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            Text("pts")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#555555"))
                        }
                    }

                    // Category
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Category", systemImage: "square.grid.2x2.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(hex: "#666666"))

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                            ForEach(Task.TaskCategory.allCases, id: \.self) { cat in
                                Button {
                                    withAnimation(.spring(response: 0.2)) { category = cat }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: cat.icon)
                                            .font(.system(size: 11))
                                        Text(cat.rawValue)
                                            .font(.system(size: 11, weight: .semibold))
                                    }
                                    .foregroundColor(category == cat ? .white : Color(hex: "#666666"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(category == cat ? cat.color.opacity(0.25) : Color(hex: "#1A1A1A"))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(category == cat ? cat.color : Color.clear, lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Recurrence
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Recurrence", systemImage: "arrow.clockwise")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(hex: "#666666"))

                        HStack(spacing: 8) {
                            ForEach(Task.Recurrence.allCases, id: \.self) { rec in
                                Button {
                                    withAnimation(.spring(response: 0.2)) { recurrence = rec }
                                } label: {
                                    Text(rec.rawValue)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(recurrence == rec ? .black : Color(hex: "#666666"))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(recurrence == rec ? Color(hex: "#F5A623") : Color(hex: "#1A1A1A"))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Due date
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Due Date", systemImage: "calendar")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(hex: "#666666"))

                        DatePicker("", selection: $dueDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .colorScheme(.dark)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            // Save button
            Button {
                guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                let task = Task(
                    title: title,
                    points: points,
                    dueDate: dueDate,
                    category: category,
                    recurrence: recurrence
                )
                store.addTask(task)
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Task")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundColor(title.isEmpty ? Color(hex: "#444444") : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(title.isEmpty ? Color(hex: "#1E1E1E") : Color(hex: "#F5A623"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(title.isEmpty)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(hex: "#0F0F0F"))
        .frame(width: 360)
    }
}
