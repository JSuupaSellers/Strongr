import Foundation
import CoreData

/// Implementation of StatsServiceProtocol that uses our repository pattern
class RepositoryStatsService: StatsServiceProtocol {
    private let statsService: any StatsService
    private let dataService: DataServiceProtocol
    private let unitService: UnitServiceProtocol
    
    init(
        statsService: any StatsService,
        dataService: DataServiceProtocol,
        unitService: UnitServiceProtocol
    ) {
        self.statsService = statsService
        self.dataService = dataService
        self.unitService = unitService
    }
    
    func calculateWorkoutStats(for user: User, workouts: [Workout]) -> WorkoutStats {
        var stats = WorkoutStats()
        
        // Total workouts
        stats.totalWorkouts = workouts.count
        
        // This week's workouts
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        
        stats.workoutsThisWeek = workouts.filter { workout in
            guard let date = workout.date else { return false }
            return date >= startOfWeek
        }.count
        
        // Total duration
        stats.totalDuration = workouts.reduce(0) { $0 + ($1.duration) }
        
        // Total sets
        stats.totalSets = workouts.reduce(0) { total, workout in
            guard let sets = workout.sets as? Set<WorkoutSet> else { return total }
            return total + sets.count
        }
        
        // Unique exercises
        var exerciseIDs = Set<NSManagedObjectID>()
        for workout in workouts {
            guard let sets = workout.sets as? Set<WorkoutSet> else { continue }
            for set in sets {
                if let exercise = set.exercise {
                    exerciseIDs.insert(exercise.objectID)
                }
            }
        }
        stats.uniqueExercises = exerciseIDs.count
        
        // Current streak
        let streakInfo = calculateStreak(for: user, workouts: workouts)
        stats.currentStreak = streakInfo.current
        
        // Consistency score (percentage of days with workouts in the last 30 days)
        stats.consistency = calculateConsistency(for: user, workouts: workouts)
        
        return stats
    }
    
    func getRecentPersonalRecords(for user: User, workouts: [Workout]) -> [PersonalRecord] {
        // Get unique exercises from these workouts
        var exercises = Set<Exercise>()
        for workout in workouts {
            guard let sets = workout.sets as? Set<WorkoutSet> else { continue }
            for set in sets {
                if let exercise = set.exercise {
                    exercises.insert(exercise)
                }
            }
        }
        
        var records: [PersonalRecord] = []
        
        // Get personal records for each exercise
        for exercise in exercises {
            let history = getExerciseHistory(for: user, exercise: exercise, workouts: workouts)
            
            // Find the most recent PR
            if let mostRecentPR = history.first {
                records.append(PersonalRecord(
                    exerciseName: exercise.name ?? "Unknown Exercise",
                    weight: mostRecentPR.maxWeight,
                    reps: mostRecentPR.repsAtMaxWeight,
                    date: mostRecentPR.date ?? Date()
                ))
            }
        }
        
        // Sort by date (most recent first)
        records.sort { $0.date > $1.date }
        
        return records
    }
    
    func calculateStreak(for user: User, workouts: [Workout]) -> (current: Int, longest: Int) {
        let calendar = Calendar.current
        
        // Get workouts sorted by date
        let sortedWorkouts = workouts.filter { $0.date != nil }
            .sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
        
        guard !sortedWorkouts.isEmpty else {
            return (0, 0)
        }
        
        // Get unique workout dates
        var workoutDays = Set<Date>()
        for workout in sortedWorkouts {
            if let date = workout.date {
                let dayStart = calendar.startOfDay(for: date)
                workoutDays.insert(dayStart)
            }
        }
        
        let workoutDaysArray = Array(workoutDays).sorted(by: >)
        
        // Calculate current streak
        var currentStreak = 1
        var longestStreak = 1
        let today = calendar.startOfDay(for: Date())
        
        // Check if there's a workout today
        let hasWorkoutToday = workoutDaysArray.contains(today)
        
        // If no workout today, start from yesterday
        var currentDate = hasWorkoutToday ? today : calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Check for consecutive days with workouts in reverse
        for i in 0..<min(workoutDaysArray.count - 1, 60) { // Limit check to 60 days
            let prevDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            
            if workoutDaysArray.contains(prevDate) {
                currentStreak += 1
                currentDate = prevDate
                longestStreak = max(longestStreak, currentStreak)
            } else {
                break
            }
        }
        
        // Reset current streak if no workout today
        if !hasWorkoutToday && currentStreak > 0 {
            currentStreak = 0
        }
        
        return (currentStreak, longestStreak)
    }
    
    func formatWeight(_ weight: Double, unitSystem: UnitSystem) -> String {
        return String(format: "%.1f %@", weight, unitSystem == .metric ? "kg" : "lbs")
    }
    
    // MARK: - Helper methods
    
    private func calculateConsistency(for user: User, workouts: [Workout]) -> Double {
        let calendar = Calendar.current
        let today = Date()
        
        // Get the date 30 days ago
        guard let startDate = calendar.date(byAdding: .day, value: -29, to: today) else {
            return 0.0
        }
        
        // Create a date interval for the last 30 days
        let dateInterval = DateInterval(start: startDate, end: today)
        let totalDays = 30 // Fixed at 30 days
        
        // Get workouts within this interval
        let workoutsInRange = workouts.filter { workout in
            guard let date = workout.date else { return false }
            return dateInterval.contains(date)
        }
        
        // Count unique days with workouts
        var daysWithWorkouts = Set<Date>()
        for workout in workoutsInRange {
            if let date = workout.date {
                let dayStart = calendar.startOfDay(for: date)
                daysWithWorkouts.insert(dayStart)
            }
        }
        
        let uniqueDaysWithWorkouts = daysWithWorkouts.count
        
        // Calculate consistency percentage
        let consistency = Double(uniqueDaysWithWorkouts) / Double(totalDays)
        
        return min(consistency, 1.0) // Cap at 100%
    }
    
    private func getExerciseHistory(for user: User, exercise: Exercise, workouts: [Workout]) -> [(date: Date, maxWeight: Double, repsAtMaxWeight: Int16)] {
        var history: [(date: Date, maxWeight: Double, repsAtMaxWeight: Int16)] = []
        
        // Get all sets for this exercise across workouts
        for workout in workouts {
            guard let date = workout.date,
                  let sets = workout.sets as? Set<WorkoutSet> else { continue }
            
            // Filter sets for this exercise
            let exerciseSets = sets.filter { $0.exercise == exercise }
            
            // Find max weight for this workout
            if let maxWeightSet = exerciseSets.max(by: { $0.weight < $1.weight }) {
                history.append((
                    date: date,
                    maxWeight: maxWeightSet.weight,
                    repsAtMaxWeight: maxWeightSet.reps
                ))
            }
        }
        
        // Sort by date (newest first)
        history.sort { $0.date > $1.date }
        
        return history
    }
} 