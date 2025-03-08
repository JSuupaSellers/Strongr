import Foundation
import CoreData

/// Protocol defining data operations
protocol DataServiceProtocol {
    /// Get the current user
    func getCurrentUser() -> User?
    
    /// Get all workouts for a user
    func getWorkouts(for user: User) -> [Workout]
    
    /// Get recent workouts for a user, limited to a specific count
    func getRecentWorkouts(for user: User, limit: Int) -> [Workout]
    
    /// Create a new workout for a user
    func createWorkout(for user: User, date: Date, name: String) -> Workout
    
    /// Get upcoming scheduled workouts
    func getUpcomingScheduledWorkouts(limit: Int) -> [ScheduledWorkoutInfo]
    
    /// Get exercise history for a user
    func getExerciseHistory(for user: User, since date: Date) -> [ExerciseHistory]
    
    /// Save changes to the data store
    func saveContext()
    
    /// Create a new user
    func createUser(name: String, weight: Double?, height: Double?, age: Int16?) -> User
    
    /// Get the Core Data context for direct access when needed
    var context: NSManagedObjectContext { get }
} 