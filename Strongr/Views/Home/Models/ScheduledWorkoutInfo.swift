import Foundation
import CoreData

// Data structure for upcoming workouts
struct ScheduledWorkoutInfo: Identifiable {
    let id: UUID
    let dayOfWeek: Int16
    let dayName: String
    let date: Date
    let formattedDate: String?
    let timeOfDay: Date?
    let formattedTime: String?
    let workout: Workout?
    let notes: String?
} 