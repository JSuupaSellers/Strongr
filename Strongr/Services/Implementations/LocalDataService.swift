import Foundation
import CoreData

class LocalDataService: DataServiceProtocol {
    private let dataManager: DataManager
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    var context: NSManagedObjectContext {
        return dataManager.context
    }
    
    func getCurrentUser() -> User? {
        return dataManager.getCurrentUser()
    }
    
    func getWorkouts(for user: User) -> [Workout] {
        return dataManager.getWorkouts(for: user)
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
        return dataManager.createWorkout(for: user, date: date, name: name)
    }
    
    func getUpcomingScheduledWorkouts(limit: Int) -> [ScheduledWorkoutInfo] {
        // Fetch active schedule
        let scheduleRequest = NSFetchRequest<WorkoutSchedule>(entityName: "WorkoutSchedule")
        scheduleRequest.predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true))
        scheduleRequest.fetchLimit = 1
        
        var upcomingInfo: [ScheduledWorkoutInfo] = []
        
        do {
            let schedules = try dataManager.context.fetch(scheduleRequest)
            guard let activeSchedule = schedules.first else { return [] }
            
            // Get current date info
            let today = Date()
            let calendar = Calendar.current
            
            // Fetch upcoming days of scheduled workouts
            for dayOffset in 0..<5 {
                // Calculate the actual date for this weekday
                var dateComponent = DateComponents()
                dateComponent.day = dayOffset
                let targetDate = calendar.date(byAdding: dateComponent, to: today)!
                
                // Get the weekday of the target date
                let targetWeekday = calendar.component(.weekday, from: targetDate)
                let dayOfWeek = Int16(targetWeekday)
                
                // Fetch scheduled workouts for this day
                let workoutRequest = NSFetchRequest<ScheduledWorkout>(entityName: "ScheduledWorkout")
                workoutRequest.predicate = NSPredicate(format: "schedule = %@ AND dayOfWeek = %d", activeSchedule, dayOfWeek)
                workoutRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ScheduledWorkout.timeOfDay, ascending: true)]
                
                if let scheduledWorkouts = try? dataManager.context.fetch(workoutRequest), !scheduledWorkouts.isEmpty {
                    for scheduledWorkout in scheduledWorkouts {
                        let info = ScheduledWorkoutInfo(
                            id: scheduledWorkout.id ?? UUID(),
                            dayOfWeek: scheduledWorkout.dayOfWeek,
                            dayName: getDayName(for: scheduledWorkout.dayOfWeek),
                            date: targetDate,
                            formattedDate: formatDate(targetDate),
                            timeOfDay: scheduledWorkout.timeOfDay,
                            formattedTime: scheduledWorkout.timeOfDay != nil ? formatTime(scheduledWorkout.timeOfDay!) : nil,
                            workout: scheduledWorkout.workout,
                            notes: scheduledWorkout.notes
                        )
                        upcomingInfo.append(info)
                    }
                }
                
                // If we have reached the limit, stop looking for more
                if upcomingInfo.count >= limit {
                    break
                }
            }
        } catch {
            print("Error fetching scheduled workouts: \(error)")
        }
        
        return upcomingInfo
    }
    
    func getExerciseHistory(for user: User, since date: Date) -> [ExerciseHistory] {
        let fetchRequest: NSFetchRequest<ExerciseHistory> = ExerciseHistory.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "user == %@ AND date >= %@",
            user, date as NSDate
        )
        
        do {
            return try dataManager.context.fetch(fetchRequest)
        } catch {
            print("Error fetching exercise history: \(error)")
            return []
        }
    }
    
    // MARK: - Helper Methods
    
    private func getDayName(for dayOfWeek: Int16) -> String {
        let weekdaySymbols = Calendar.current.weekdaySymbols
        let index = Int(dayOfWeek - 1)
        if index >= 0 && index < weekdaySymbols.count {
            return weekdaySymbols[index]
        }
        return "Day \(dayOfWeek)"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
} 