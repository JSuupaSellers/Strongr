//
//  ExerciseDetailView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI
import CoreData

struct ExerciseDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    var exercise: Exercise
    
    @State private var historicalSets: [WorkoutSet] = []
    @State private var groupedSets: [Date?: [WorkoutSet]] = [:]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header card with exercise info
                exerciseHeaderCard
                
                // Performance stats card (if available)
                if !historicalSets.isEmpty {
                    performanceStatsCard
                }
                
                // Exercise history
                if !historicalSets.isEmpty {
                    exerciseHistorySection
                } else {
                    noHistoryMessage
                }
                
                // Bottom padding for better spacing
                Spacer().frame(height: 20)
            }
            .padding(.horizontal)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(exercise.name ?? "Exercise")
        .onAppear {
            loadExerciseHistory()
        }
    }
    
    // MARK: - UI Components
    
    private var exerciseHeaderCard: some View {
        VStack(spacing: 16) {
            // Category and muscle tags
            HStack(spacing: 12) {
                if let category = exercise.category, !category.isEmpty {
                    categoryBadge(category)
                }
                
                if let targetMuscleGroup = exercise.targetMuscleGroup, !targetMuscleGroup.isEmpty {
                    muscleBadge(targetMuscleGroup)
                }
                
                Spacer()
            }
            
            // Description
            if let description = exercise.exerciseDescription, !description.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("About this exercise")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(description)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    private var performanceStatsCard: some View {
        HStack(spacing: 20) {
            // Total sets performed
            statItem(
                value: "\(historicalSets.count)",
                label: "TOTAL SETS",
                icon: "repeat"
            )
            
            // Max weight (if applicable)
            if maxWeight > 0 {
                statItem(
                    value: "\(String(format: "%.1f", maxWeight)) kg",
                    label: "MAX WEIGHT",
                    icon: "scalemass"
                )
            }
            
            // Max reps (if applicable)
            if maxReps > 0 {
                statItem(
                    value: "\(maxReps)",
                    label: "MAX REPS",
                    icon: "chart.bar.fill"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    private var exerciseHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WORKOUT HISTORY")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ForEach(getOrderedDates(), id: \.self) { date in
                if let sets = groupedSets[date], let date = date {
                    workoutHistoryCard(date: date, sets: sets)
                }
            }
        }
    }
    
    private func workoutHistoryCard(date: Date, sets: [WorkoutSet]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedDate(date))
                        .font(.headline)
                    
                    if let workoutName = sets.first?.workout?.name {
                        Text(workoutName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text("\(sets.count) sets")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            // Sets list
            VStack(spacing: 0) {
                ForEach(sets) { set in
                    VStack {
                        Divider()
                        historySetRow(for: set)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                    }
                }
            }
            
            // Bottom padding
            Spacer().frame(height: 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    private var noHistoryMessage: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
                .padding(.top, 20)
            
            Text("No Exercise History")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Complete workouts with this exercise to build history and track your progress.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 20)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    private func historySetRow(for set: WorkoutSet) -> some View {
        HStack(spacing: 12) {
            // Set number indicator
            ZStack {
                Circle()
                    .fill(set.completed ? Color.green.opacity(0.15) : Color.blue.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Text("\(set.setNumber)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(set.completed ? .green : .blue)
            }
            
            // Set details
            HStack(spacing: 16) {
                if set.weight > 0 {
                    metricView(
                        value: String(format: "%.1f", set.weight),
                        unit: "kg",
                        icon: "scalemass.fill"
                    )
                }
                
                if set.reps > 0 {
                    metricView(
                        value: "\(set.reps)",
                        unit: "reps",
                        icon: "repeat"
                    )
                }
                
                if set.timeSeconds > 0 {
                    metricView(
                        value: formatTime(set.timeSeconds),
                        unit: "",
                        icon: "timer",
                        highlighted: true
                    )
                }
            }
            
            Spacer()
            
            // Completion indicator
            if set.completed {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.green)
            }
        }
    }
    
    // Helper Components
    
    private func categoryBadge(_ category: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: categoryIcon(for: category))
                .font(.system(size: 12))
            
            Text(category)
                .font(.system(size: 14, weight: .medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(categoryColor(for: category).opacity(0.15))
        .foregroundColor(categoryColor(for: category))
        .cornerRadius(8)
    }
    
    private func muscleBadge(_ muscle: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 12))
            
            Text(muscle)
                .font(.system(size: 14, weight: .medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.purple.opacity(0.15))
        .foregroundColor(.purple)
        .cornerRadius(8)
    }
    
    private func metricView(value: String, unit: String, icon: String, highlighted: Bool = false) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(highlighted ? .blue : .secondary)
            
            Text("\(value)\(unit.isEmpty ? "" : " \(unit)")")
                .font(.system(size: 12))
                .foregroundColor(highlighted ? .blue : .primary)
        }
    }
    
    private func statItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func categoryIcon(for category: String) -> String {
        switch category {
            case "Strength": return "dumbbell.fill"
            case "Cardio": return "heart.fill"
            case "Bodyweight": return "figure.walk"
            case "Stretching": return "figure.mixed.cardio"
            case "Custom": return "star.fill"
            default: return "tag.fill"
        }
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category {
            case "Strength": return .blue
            case "Cardio": return .red
            case "Bodyweight": return .green
            case "Stretching": return .purple
            case "Custom": return .orange
            default: return .gray
        }
    }
    
    // MARK: - Data Helpers
    
    private var maxWeight: Double {
        historicalSets.map { $0.weight }.max() ?? 0
    }
    
    private var maxReps: Int16 {
        historicalSets.map { $0.reps }.max() ?? 0
    }
    
    private func loadExerciseHistory() {
        let fetchRequest: NSFetchRequest<WorkoutSet> = WorkoutSet.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "exercise == %@", exercise)
        
        do {
            historicalSets = try dataManager.context.fetch(fetchRequest)
            organizeSetsByWorkout()
        } catch {
            print("Error fetching workout sets: \(error)")
            historicalSets = []
        }
    }
    
    private func organizeSetsByWorkout() {
        // Create a new empty dictionary
        var newGrouped = [Date?: [WorkoutSet]]()
        
        // Group sets by date
        for set in historicalSets {
            let date = set.workout?.date
            
            if newGrouped[date] == nil {
                newGrouped[date] = [set]
            } else {
                newGrouped[date]?.append(set)
            }
        }
        
        // Manually sort sets within each workout
        for (date, setsArray) in newGrouped {
            // Sort sets by setNumber using a simple array sort
            let orderedSets = setsArray.sorted { (set1, set2) -> Bool in
                return set1.setNumber < set2.setNumber
            }
            newGrouped[date] = orderedSets
        }
        
        // Assign the result
        groupedSets = newGrouped
    }
    
    private func getOrderedDates() -> [Date?] {
        // Manually create an array of dates
        let dates = Array(groupedSets.keys)
        
        // Sort the dates using a simple array sort
        return dates.sorted { (date1, date2) -> Bool in
            if let d1 = date1, let d2 = date2 {
                // If both dates exist, sort newest first
                return d1 > d2
            } else if date1 == nil {
                // Nil dates go last
                return false
            } else {
                // Non-nil dates before nil dates
                return true
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(remainingSeconds)s"
        } else {
            return "\(remainingSeconds)s"
        }
    }
} 