import Foundation
import CoreData

/// Repository protocol for Exercise entity operations
protocol ExerciseRepository: Repository where Entity == Exercise {
    /// Fetch exercises by name
    func getExerciseByName(_ name: String) -> Exercise?
    
    /// Fetch exercises by category
    func getExercisesByCategory(_ category: String) -> [Exercise]
    
    /// Fetch exercises by muscle group
    func getExercisesByMuscleGroup(_ muscleGroup: String) -> [Exercise]
    
    /// Create a new exercise with the given properties
    func createExercise(name: String, category: String?, targetMuscleGroup: String?, description: String?) -> Exercise
    
    /// Get count of all exercises
    func getExerciseCount() -> Int
} 