import Foundation
import CoreData

/// Core Data implementation of StatsService
class CoreDataStatsService: StatsService {
    private let context: NSManagedObjectContext
    private let workoutRepository: any WorkoutRepository
    
    init(context: NSManagedObjectContext, workoutRepository: any WorkoutRepository) {
        self.context = context
        self.workoutRepository = workoutRepository
    }
    
    func getPersonalRecords(for user: User, exercise: Exercise) -> (maxWeight: Double, maxReps: Int16) {
        let request: NSFetchRequest<WorkoutSet> = WorkoutSet.fetchRequest()
        request.predicate = NSPredicate(format: "exercise == %@ AND workout.user == %@", exercise, user)
        
        do {
            let sets = try context.fetch(request)
            
            // Find max weight and max reps across all sets
            var maxWeight: Double = 0
            var maxReps: Int16 = 0
            
            for set in sets {
                if set.weight > maxWeight {
                    maxWeight = set.weight
                }
                
                if set.reps > maxReps {
                    maxReps = set.reps
                }
            }
            
            return (maxWeight: maxWeight, maxReps: maxReps)
        } catch {
            print("Error fetching personal records: \(error)")
            return (maxWeight: 0, maxReps: 0)
        }
    }
    
    func getTotalVolumeLifted(for user: User, in timeRange: DateInterval?) -> Double {
        // Get all workouts for the user in the time range
        let workouts: [Workout]
        
        if let timeRange = timeRange {
            workouts = workoutRepository.getWorkoutsInDateRange(timeRange, for: user)
        } else {
            workouts = workoutRepository.getWorkoutsForUser(user)
        }
        
        // Sum up total volume (weight * reps) across all sets
        var totalVolume: Double = 0
        
        for workout in workouts {
            if let sets = workout.sets as? Set<WorkoutSet> {
                for set in sets {
                    totalVolume += Double(set.reps) * set.weight
                }
            }
        }
        
        return totalVolume
    }
    
    func getWorkoutFrequency(for user: User, in timeRange: DateInterval?) -> [Date: Int] {
        // Get all workouts for the user in the time range
        let workouts: [Workout]
        
        if let timeRange = timeRange {
            workouts = workoutRepository.getWorkoutsInDateRange(timeRange, for: user)
        } else {
            workouts = workoutRepository.getWorkoutsForUser(user)
        }
        
        // Group workouts by day
        var frequency: [Date: Int] = [:]
        let calendar = Calendar.current
        
        for workout in workouts {
            // Get start of day for consistency
            let startOfDay = calendar.startOfDay(for: workout.date ?? Date())
            
            // Increment count for this day
            frequency[startOfDay, default: 0] += 1
        }
        
        return frequency
    }
    
    func getExerciseProgress(for user: User, exercise: Exercise, timeRange: DateInterval?) -> [(date: Date, weight: Double, reps: Int16)] {
        let request: NSFetchRequest<WorkoutSet> = WorkoutSet.fetchRequest()
        
        // Create predicates for user and exercise
        var predicates: [NSPredicate] = [
            NSPredicate(format: "exercise == %@", exercise),
            NSPredicate(format: "workout.user == %@", user)
        ]
        
        // Add date range predicate if provided
        if let timeRange = timeRange {
            predicates.append(NSPredicate(format: "workout.date >= %@ AND workout.date <= %@", 
                                         timeRange.start as NSDate, 
                                         timeRange.end as NSDate))
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: "workout.date", ascending: true)]
        
        do {
            let sets = try context.fetch(request)
            
            // Map sets to progress data points
            var progressPoints: [(date: Date, weight: Double, reps: Int16)] = []
            
            for set in sets {
                if let date = set.workout?.date {
                    progressPoints.append((date: date, weight: set.weight, reps: set.reps))
                }
            }
            
            return progressPoints
        } catch {
            print("Error fetching exercise progress: \(error)")
            return []
        }
    }
} 