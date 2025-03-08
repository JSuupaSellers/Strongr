import Foundation
import CoreData

/// Repository protocol for WorkoutSet entity operations
protocol WorkoutSetRepository: Repository where Entity == WorkoutSet {
    /// Add a set to a workout
    func addSet(to workout: Workout, exercise: Exercise, reps: Int16?, weight: Double?, timeSeconds: Double?) -> WorkoutSet
    
    /// Update an existing set
    func updateSet(_ set: WorkoutSet, reps: Int16?, weight: Double?, timeSeconds: Double?)
    
    /// Get all sets for a specific workout
    func getSetsForWorkout(_ workout: Workout) -> [WorkoutSet]
    
    /// Get all sets for a specific exercise in a workout
    func getSetsForExercise(_ exercise: Exercise, in workout: Workout) -> [WorkoutSet]
} 