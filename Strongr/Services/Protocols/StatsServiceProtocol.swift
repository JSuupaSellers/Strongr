import Foundation
import CoreData

/// Protocol defining statistics calculation operations
protocol StatsServiceProtocol {
    /// Calculate comprehensive workout statistics for a user
    func calculateWorkoutStats(for user: User, workouts: [Workout]) -> WorkoutStats
    
    /// Get recent personal records for a user
    func getRecentPersonalRecords(for user: User, workouts: [Workout]) -> [PersonalRecord]
    
    /// Calculate the current and longest workout streak for a user
    func calculateStreak(for user: User, workouts: [Workout]) -> (current: Int, longest: Int)
    
    /// Format a weight value according to the current unit system
    func formatWeight(_ weight: Double, unitSystem: UnitSystem) -> String
}

/// Data structure for personal records
struct PersonalRecord: Identifiable {
    let id = UUID()
    let exerciseName: String
    let weight: Double
    let reps: Int16
    let date: Date
} 