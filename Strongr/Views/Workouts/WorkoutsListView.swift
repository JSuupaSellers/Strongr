//
//  WorkoutsListView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI
import CoreData

struct WorkoutsListView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var unitManager: UnitManager
    @State private var workouts: [Workout] = []
    @State private var groupedWorkouts: [String: [Workout]] = [:]
    @State private var showingNewWorkoutSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // New workout button
                addWorkoutButton
                    .padding(.top, 8)
                
                // Workouts list
                if workouts.isEmpty {
                    emptyStateView
                } else {
                    workoutsContent
                }
            }
            .padding(.horizontal)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Workout History")
        .sheet(isPresented: $showingNewWorkoutSheet) {
            NewWorkoutView(
                currentUser: dataManager.getCurrentUser(), 
                isPresented: $showingNewWorkoutSheet, 
                onSave: {
                    loadWorkouts()
                }
            )
        }
        .onAppear {
            loadWorkouts()
        }
    }
    
    // MARK: - UI Components
    
    private var addWorkoutButton: some View {
        Button(action: {
            showingNewWorkoutSheet = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                
                Text("New Workout")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 70))
                .foregroundColor(.gray.opacity(0.5))
                .padding(.bottom, 16)
            
            Text("No Workouts Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Create your first workout to start tracking your fitness journey")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }
    
    private var workoutsContent: some View {
        VStack(spacing: 24) {
            ForEach(getSortedMonths(), id: \.self) { month in
                if let workoutsInMonth = groupedWorkouts[month] {
                    monthSection(month: month, workouts: workoutsInMonth)
                }
            }
        }
    }
    
    private func monthSection(month: String, workouts: [Workout]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Month header
            Text(month.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.leading, 8)
            
            // Workout cards
            ForEach(workouts) { workout in
                workoutCard(for: workout)
            }
        }
    }
    
    private func workoutCard(for workout: Workout) -> some View {
        NavigationLink(destination: WorkoutDetailView(workout: workout)
            .environmentObject(dataManager)
            .environmentObject(unitManager)) {
            VStack(spacing: 0) {
                // Card content
                VStack(alignment: .leading, spacing: 12) {
                    // Title and date
                    HStack {
                        Text(workout.name ?? "Workout")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if let date = workout.date {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(dateFormatter.string(from: date))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Stats overview
                    HStack(spacing: 16) {
                        if let duration = workout.duration as? Double, duration > 0 {
                            statView(value: formatDuration(duration), icon: "clock")
                        }
                        
                        if let sets = workout.sets as? Set<WorkoutSet> {
                            statView(value: "\(sets.count) sets", icon: "repeat")
                            
                            let exercises = Set(sets.compactMap { $0.exercise?.name })
                            statView(value: "\(exercises.count) exercises", icon: "dumbbell")
                            
                            let completedCount = sets.filter { $0.completed }.count
                            if !sets.isEmpty {
                                let percentage = Int((Double(completedCount) / Double(sets.count)) * 100)
                                statView(
                                    value: "\(percentage)% completed",
                                    icon: "checkmark.circle",
                                    color: percentage > 0 ? .green : .gray
                                )
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Bottom actions bar
                HStack {
                    Spacer()
                    
                    Menu {
                        Button(action: {
                            if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
                                deleteWorkouts(at: IndexSet([index]), in: workouts)
                            }
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                }
                .background(Color(.systemBackground).opacity(0.95))
                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
            }
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
            .padding(.bottom, 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func statView(value: String, icon: String, color: Color = .blue) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color.opacity(0.8))
            
            Text(value)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Helper Functions
    
    private func getSortedMonths() -> [String] {
        return groupedWorkouts.keys.sorted(by: >)
    }
    
    private func loadWorkouts() {
        workouts = dataManager.getWorkouts(for: dataManager.getCurrentUser())
        groupWorkoutsByMonth()
    }
    
    private func groupWorkoutsByMonth() {
        let calendar = Calendar.current
        
        var grouped = [String: [Workout]]()
        
        for workout in workouts {
            guard let date = workout.date else { continue }
            
            let month = monthYearFormatter.string(from: date)
            if grouped[month] == nil {
                grouped[month] = [workout]
            } else {
                grouped[month]?.append(workout)
            }
        }
        
        // Sort workouts within each month by date (newest first)
        for (month, workoutsInMonth) in grouped {
            grouped[month] = workoutsInMonth.sorted {
                guard let date1 = $0.date, let date2 = $1.date else { return false }
                return date1 > date2
            }
        }
        
        groupedWorkouts = grouped
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    private func deleteWorkouts(at offsets: IndexSet, in workoutsInMonth: [Workout]) {
        // Get the workouts to delete
        let workoutsToDelete = offsets.map { workoutsInMonth[$0] }
        
        // Delete each workout using the dataManager's method that preserves history
        for workout in workoutsToDelete {
            dataManager.deleteWorkout(workout)
        }
        
        // No need to call saveContext here as deleteWorkout does that internally
        
        // Reload the data
        loadWorkouts()
    }
    
    private func formatDuration(_ duration: Double) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) min"
        }
    }
}

// Extension for rounded corners on specific edges
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
} 