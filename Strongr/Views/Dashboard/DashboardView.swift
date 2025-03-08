//
//  DashboardView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI
import CoreData

// MARK: - Dashboard View
struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var unitManager: UnitManager
    @Binding var currentUser: User?
    
    @State private var workouts: [Workout] = []
    @State private var workoutsByWeek: [Date: Int] = [:]
    @State private var totalWorkoutCount: Int = 0
    @State private var favoriteExercise: String = "--"
    @State private var longestStreak: Int = 0
    @State private var currentStreak: Int = 0
    @State private var isInitialLoad = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    welcomeSection
                    
                    statsSection
                    
                    activitySection
                    
                    recentWorkoutsSection
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .onAppear {
                if isInitialLoad {
                    loadData()
                    isInitialLoad = false
                }
            }
        }
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome, \(currentUser?.name ?? "Athlete")")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Track your progress and crush your goals")
                .foregroundColor(.secondary)
        }
    }
    
    private var statsSection: some View {
        VStack(spacing: 15) {
            Text("Your Stats")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                StatCard(
                    title: "Workouts",
                    value: "\(totalWorkoutCount)",
                    icon: "figure.strengthtraining.traditional",
                    color: .blue,
                    change: ""
                )
                
                StatCard(
                    title: "Current Streak",
                    value: "\(currentStreak)",
                    icon: "flame.fill",
                    color: .orange,
                    change: ""
                )
                
                StatCard(
                    title: "Longest Streak",
                    value: "\(longestStreak)",
                    icon: "trophy.fill",
                    color: .green,
                    change: ""
                )
            }
            
            if !favoriteExercise.isEmpty && favoriteExercise != "--" {
                HStack {
                    Text("Favorite Exercise:")
                        .foregroundColor(.secondary)
                    Text(favoriteExercise)
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var activitySection: some View {
        VStack(spacing: 15) {
            Text("Weekly Activity")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 4) {
                ForEach(getLastFourWeeks(), id: \.self) { weekStart in
                    let count = workoutsByWeek[weekStart] ?? 0
                    VStack {
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 100)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue)
                                .frame(height: count > 0 ? min(CGFloat(count * 25), 100) : 0)
                        }
                        .frame(height: 100)
                        
                        Text(getWeekLabel(for: weekStart))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 10)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var recentWorkoutsSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Recent Workouts")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: WorkoutsListView()) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            if workouts.isEmpty {
                Text("No workouts recorded yet")
                    .foregroundColor(.secondary)
                    .italic()
                    .padding()
            } else {
                ForEach(Array(workouts.prefix(3))) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)
                                    .environmentObject(dataManager)
                                    .environmentObject(unitManager)) {
                        WorkoutCard(workout: workout)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func loadData() {
        // Load user
        currentUser = dataManager.getCurrentUser()
        
        // Load workouts
        workouts = dataManager.getWorkouts(for: currentUser).sorted {
            $0.date ?? Date() > $1.date ?? Date()
        }
        
        totalWorkoutCount = workouts.count
        
        // Calculate workout activity by week
        calculateWorkoutsByWeek()
        
        // Find favorite exercise
        favoriteExercise = findFavoriteExercise() ?? "--"
        
        // Calculate streaks
        calculateStreaks()
    }
    
    private func calculateWorkoutsByWeek() {
        let calendar = Calendar.current
        
        // Initialize with empty weeks
        workoutsByWeek = Dictionary(uniqueKeysWithValues: getLastFourWeeks().map { ($0, 0) })
        
        // Group workouts by week
        for workout in workouts {
            guard let date = workout.date else { continue }
            
            // Get the start of the week for this date
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
            
            // Update count for this week
            workoutsByWeek[weekStart, default: 0] += 1
        }
    }
    
    private func getLastFourWeeks() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<4).compactMap { index -> Date? in
            let dateComponents = DateComponents(day: -index * 7)
            let date = calendar.date(byAdding: dateComponents, to: today)!
            return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))
        }.reversed()
    }
    
    private func getWeekLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    private func findFavoriteExercise() -> String? {
        var exerciseCounts: [String: Int] = [:]
        
        // Count exercise occurrences across all workouts
        for workout in workouts {
            if let sets = workout.sets as? Set<WorkoutSet> {
                for set in sets {
                    if let exerciseName = set.exercise?.name {
                        exerciseCounts[exerciseName, default: 0] += 1
                    }
                }
            }
        }
        
        // Find the exercise with highest count
        return exerciseCounts.max(by: { $0.value < $1.value })?.key
    }
    
    private func calculateStreaks() {
        guard !workouts.isEmpty else { return }
        
        let calendar = Calendar.current
        let sortedDates = workouts.compactMap { $0.date }
            .map { calendar.startOfDay(for: $0) }
            .sorted()
            .map { calendar.dateComponents([.day, .month, .year], from: $0) }
        
        let today = calendar.dateComponents([.day, .month, .year], from: Date())
        
        var currentStreak = 0
        var maxStreak = 0
        var streakDays = Set<DateComponents>()
        
        // Build set of all workout days
        for dateComp in sortedDates {
            streakDays.insert(dateComp)
        }
        
        // Calculate current streak
        var checkDate = today
        while streakDays.contains(checkDate) {
            currentStreak += 1
            
            guard let previousDay = calendar.date(from: checkDate),
                  let dayBefore = calendar.date(byAdding: .day, value: -1, to: previousDay) else {
                break
            }
            
            checkDate = calendar.dateComponents([.day, .month, .year], from: dayBefore)
        }
        
        // Calculate longest streak
        var currentCount = 0
        for i in 0..<sortedDates.count {
            if i == 0 {
                currentCount = 1
                continue
            }
            
            let previousDate = calendar.date(from: sortedDates[i-1])!
            let currentDate = calendar.date(from: sortedDates[i])!
            
            let daysBetween = calendar.dateComponents([.day], from: previousDate, to: currentDate).day ?? 0
            
            if daysBetween == 1 {
                currentCount += 1
            } else {
                maxStreak = max(maxStreak, currentCount)
                currentCount = 1
            }
        }
        
        maxStreak = max(maxStreak, currentCount)
        self.currentStreak = currentStreak
        self.longestStreak = maxStreak
    }
} 