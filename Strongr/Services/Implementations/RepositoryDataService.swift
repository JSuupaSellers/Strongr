import Foundation
import CoreData

/// Implementation of DataServiceProtocol that uses our repository pattern
class RepositoryDataService: DataServiceProtocol {
    // Repositories
    private let userRepository: any UserRepository
    private let workoutRepository: any WorkoutRepository
    
    // Context must be accessible as per DataServiceProtocol
    let context: NSManagedObjectContext
    
    init(
        userRepository: any UserRepository,
        workoutRepository: any WorkoutRepository,
        context: NSManagedObjectContext
    ) {
        self.userRepository = userRepository
        self.workoutRepository = workoutRepository
        self.context = context
    }
    
    func getCurrentUser() -> User? {
        return userRepository.getCurrentUser()
    }
    
    func getWorkouts(for user: User) -> [Workout] {
        return workoutRepository.getWorkoutsForUser(user)
    }
    
    func getRecentWorkouts(for user: User, limit: Int) -> [Workout] {
        let allWorkouts = getWorkouts(for: user)
        
        // Sort workouts by date, most recent first
        let sortedWorkouts = allWorkouts.sorted { workout1, workout2 in
            guard let date1 = workout1.date, let date2 = workout2.date else { return false }
            return date1 > date2
        }
        
        // Return the most recent 'limit' workouts
        return Array(sortedWorkouts.prefix(limit))
    }
    
    func createWorkout(for user: User, date: Date, name: String) -> Workout {
        return workoutRepository.createWorkout(for: user, date: date, name: name, notes: nil)
    }
    
    func getUpcomingScheduledWorkouts(limit: Int) -> [ScheduledWorkoutInfo] {
        // Create empty array to hold results
        var upcomingInfo: [ScheduledWorkoutInfo] = []
        
        // Get current date info
        let today = Date()
        let calendar = Calendar.current
        
        // Fetch upcoming days of scheduled workouts
        for dayOffset in 0..<5 {
            // Calculate the actual date for this weekday
            let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: today)!
            
            // Get the weekday of the target date
            let targetWeekday = calendar.component(.weekday, from: targetDate)
            let dayOfWeek = Int16(targetWeekday)
            
            // Fetch scheduled workouts for this day
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ScheduledWorkout")
            fetchRequest.predicate = NSPredicate(format: "dayOfWeek == %d", dayOfWeek)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeOfDay", ascending: true)]
            
            do {
                let scheduledWorkouts = try context.fetch(fetchRequest)
                
                for scheduledWorkout in scheduledWorkouts {
                    // Safely extract values using key-value coding
                    let id = scheduledWorkout.value(forKey: "id") as? UUID ?? UUID()
                    let workoutDayOfWeek = scheduledWorkout.value(forKey: "dayOfWeek") as? Int16 ?? 0
                    let timeOfDay = scheduledWorkout.value(forKey: "timeOfDay") as? Date
                    let notes = scheduledWorkout.value(forKey: "notes") as? String
                    let workout = scheduledWorkout.value(forKey: "workout") as? Workout
                    
                    // Format date and time
                    let dayName = dayOfWeekString(from: Int(workoutDayOfWeek))
                    let formattedDate = formatDate(targetDate)
                    let formattedTime = timeOfDay != nil ? formatTime(timeOfDay!) : nil
                    
                    // Create ScheduledWorkoutInfo
                    let info = ScheduledWorkoutInfo(
                        id: id,
                        dayOfWeek: workoutDayOfWeek,
                        dayName: dayName,
                        date: targetDate,
                        formattedDate: formattedDate,
                        timeOfDay: timeOfDay,
                        formattedTime: formattedTime,
                        workout: workout,
                        notes: notes
                    )
                    
                    upcomingInfo.append(info)
                }
            } catch {
                print("Error fetching scheduled workouts: \(error)")
            }
            
            // If we have reached the limit, stop looking for more
            if upcomingInfo.count >= limit {
                break
            }
        }
        
        return upcomingInfo
    }
    
    func getExerciseHistory(for user: User, since date: Date) -> [ExerciseHistory] {
        let request = NSFetchRequest<ExerciseHistory>(entityName: "ExerciseHistory")
        request.predicate = NSPredicate(format: "user == %@ AND date >= %@", user, date as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching exercise history: \(error)")
            return []
        }
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    func createUser(name: String, weight: Double?, height: Double?, age: Int16?) -> User {
        return userRepository.createUser(name: name, weight: weight, height: height, age: age)
    }
    
    // MARK: - Helper Methods
    
    private func nextDateForWeekday(_ weekday: Int, from date: Date) -> Date? {
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: date)
        
        var daysToAdd = weekday - currentWeekday
        if daysToAdd < 0 {
            daysToAdd += 7
        } else if daysToAdd == 0 {
            // If it's the same day, we still include it
            daysToAdd = 0
        }
        
        return calendar.date(byAdding: .day, value: daysToAdd, to: date)
    }
    
    private func dayOfWeekString(from weekday: Int) -> String {
        let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        // Adjust index since weekdays are 1-based in Calendar
        let index = (weekday - 1) % 7
        
        return weekdays[index]
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
} 