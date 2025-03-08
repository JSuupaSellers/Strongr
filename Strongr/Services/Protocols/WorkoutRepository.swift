import Foundation
import CoreData

/// Repository protocol for Workout entity operations
protocol WorkoutRepository: Repository where Entity == Workout {
    /// Fetch workouts for a specific user
    func getWorkoutsForUser(_ user: User?) -> [Workout]
    
    /// Fetch workouts within a date range
    func getWorkoutsInDateRange(_ range: DateInterval, for user: User?) -> [Workout]
    
    /// Create a new workout with the given properties
    func createWorkout(for user: User, date: Date, name: String?, notes: String?) -> Workout
    
    /// Complete a workout with the given duration
    func completeWorkout(_ workout: Workout, duration: Double)
    
    /// Create a copy of a workout template for a user
    func createWorkoutFromTemplate(_ template: Workout, for user: User) -> Workout
} 