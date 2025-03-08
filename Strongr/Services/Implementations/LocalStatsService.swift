import Foundation
import CoreData

class LocalStatsService: StatsServiceProtocol {
    private let dataService: DataServiceProtocol
    
    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
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
        
        // Workout consistency (workouts per week over the last month)
        if !workouts.isEmpty {
            let monthAgo = calendar.date(byAdding: .day, value: -30, to: today) ?? today
            let workoutsLastMonth = workouts.filter { workout in
                guard let date = workout.date else { return false }
                return date >= monthAgo
            }
            
            if !workoutsLastMonth.isEmpty {
                // Calculate the average number of workouts per week
                let numberOfWorkouts = workoutsLastMonth.count
                let daysBetween = max(1, calendar.dateComponents([.day], from: monthAgo, to: today).day ?? 30)
                stats.consistency = Double(numberOfWorkouts) / (Double(daysBetween) / 7.0)
            }
        }
        
        return stats
    }
    
    func getRecentPersonalRecords(for user: User, workouts: [Workout]) -> [PersonalRecord] {
        let calendar = Calendar.current
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!
        
        var prs: [PersonalRecord] = []
        var exerciseBestLifts: [NSManagedObjectID: (weight: Double, reps: Int16, date: Date)] = [:]
        
        // Find the best lift for each exercise from current workouts
        for workout in workouts {
            guard let date = workout.date, date >= oneMonthAgo else { continue }
            guard let sets = workout.sets as? Set<WorkoutSet> else { continue }
            
            for set in sets {
                guard let exercise = set.exercise else { continue }
                let exerciseID = exercise.objectID
                
                // For simplicity, track max weight (could use a more sophisticated formula)
                if let currentBest = exerciseBestLifts[exerciseID] {
                    if set.weight > currentBest.weight {
                        exerciseBestLifts[exerciseID] = (set.weight, set.reps, date)
                    }
                } else {
                    exerciseBestLifts[exerciseID] = (set.weight, set.reps, date)
                }
            }
        }
        
        // Find the best lift for each exercise from exercise history
        let historyRecords = dataService.getExerciseHistory(for: user, since: oneMonthAgo)
        
        for record in historyRecords {
            guard let exercise = record.exercise, let recordDate = record.date else { continue }
            let exerciseID = exercise.objectID
            
            if let currentBest = exerciseBestLifts[exerciseID] {
                if record.maxWeight > currentBest.weight {
                    exerciseBestLifts[exerciseID] = (record.maxWeight, record.repsAtMaxWeight, recordDate)
                }
            } else {
                exerciseBestLifts[exerciseID] = (record.maxWeight, record.repsAtMaxWeight, recordDate)
            }
        }
        
        // Convert to PR records
        for (exerciseID, liftData) in exerciseBestLifts {
            guard let exercise = try? dataService.context.existingObject(with: exerciseID) as? Exercise,
                  let name = exercise.name else { continue }
            
            prs.append(PersonalRecord(
                exerciseName: name,
                weight: liftData.weight,
                reps: liftData.reps,
                date: liftData.date
            ))
        }
        
        // Sort by date, most recent first
        return prs.sorted { $0.date > $1.date }
    }
    
    func calculateStreak(for user: User, workouts: [Workout]) -> (current: Int, longest: Int) {
        var current = 0
        var longest = 0
        
        let calendar = Calendar.current
        let today = Date()
        
        // Get sorted workout dates
        let workoutDates = workouts.compactMap { $0.date }
            .sorted(by: >)
        
        guard !workoutDates.isEmpty else { return (0, 0) }
        
        // Get all workout days (including from history)
        var workoutDays = Set<Date>()
        
        // Add dates from workouts
        for workout in workouts {
            if let date = workout.date {
                workoutDays.insert(calendar.startOfDay(for: date))
            }
        }
        
        // Add dates from exercise history
        let historyRecords = dataService.getExerciseHistory(for: user, since: calendar.date(byAdding: .year, value: -1, to: today)!)
        for record in historyRecords {
            if let date = record.date {
                workoutDays.insert(calendar.startOfDay(for: date))
            }
        }
        
        // Check if worked out today
        let todayStart = calendar.startOfDay(for: today)
        if workoutDays.contains(todayStart) {
            current = 1
        } else {
            // Check if yesterday's workout exists
            let yesterday = calendar.date(byAdding: .day, value: -1, to: todayStart)!
            if workoutDays.contains(yesterday) {
                current = 1
            } else {
                return (0, calculateLongestStreak(from: Array(workoutDays)))
            }
        }
        
        // Count consecutive days
        var checkDate = calendar.date(byAdding: .day, value: -1, to: todayStart)!
        
        while workoutDays.contains(checkDate) {
            current += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                break
            }
            checkDate = previousDay
        }
        
        longest = calculateLongestStreak(from: Array(workoutDays))
        
        return (current, longest)
    }
    
    func formatWeight(_ weight: Double, unitSystem: UnitSystem) -> String {
        let unit = unitSystem == .metric ? "kg" : "lb"
        return String(format: "%.1f \(unit)", weight)
    }
    
    // MARK: - Private Helper Methods
    
    private func calculateLongestStreak(from dates: [Date]) -> Int {
        guard !dates.isEmpty else { return 0 }
        
        var longest = 0
        var currentStreak = 1
        
        let calendar = Calendar.current
        let sortedDates = dates.sorted()
        
        guard sortedDates.count > 1 else { return 1 }
        
        for i in 1..<sortedDates.count {
            let previous = sortedDates[i-1]
            let current = sortedDates[i]
            
            let daysBetween = calendar.dateComponents([.day], from: previous, to: current).day ?? 0
            
            if daysBetween == 1 {
                currentStreak += 1
                longest = max(longest, currentStreak)
            } else if daysBetween != 0 {
                // Reset streak for gap larger than 1 day
                currentStreak = 1
            }
        }
        
        return max(longest, 1)
    }
} 