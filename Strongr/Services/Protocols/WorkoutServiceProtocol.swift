import Foundation
import SwiftUI

/// Protocol defining workout-related operations
protocol WorkoutServiceProtocol {
    /// Start a workout by opening its detail view
    func startWorkout(_ workout: Workout, dataManager: DataManager, unitManager: UnitManager)
    
    /// Create and start a new empty workout
    func createAndStartEmptyWorkout(for user: User, dataManager: DataManager, unitManager: UnitManager)
    
    /// Show a selection dialog to choose a workout to repeat
    func showQuickSelectWorkoutDialog(recentWorkouts: [Workout], dataManager: DataManager, unitManager: UnitManager)
    
    /// Get the muscle groups targeted in a workout
    func getMuscleGroups(for workout: Workout) -> String?
    
    /// Suggest a workout based on recent activity
    func getSuggestedWorkout(from recentWorkouts: [Workout]) -> Workout?
} 