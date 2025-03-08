import Foundation
import CoreData

/// Service protocol for handling statistics and analytics operations
protocol StatsService {
    /// Get personal records for a user and exercise
    func getPersonalRecords(for user: User, exercise: Exercise) -> (maxWeight: Double, maxReps: Int16)
    
    /// Get total volume lifted for a user in a specific time range
    func getTotalVolumeLifted(for user: User, in timeRange: DateInterval?) -> Double
    
    /// Get workout frequency stats for a user
    func getWorkoutFrequency(for user: User, in timeRange: DateInterval?) -> [Date: Int]
    
    /// Get progress stats for a specific exercise
    func getExerciseProgress(for user: User, exercise: Exercise, timeRange: DateInterval?) -> [(date: Date, weight: Double, reps: Int16)]
} 