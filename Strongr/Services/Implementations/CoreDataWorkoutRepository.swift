import Foundation
import CoreData

/// Core Data implementation of WorkoutRepository
class CoreDataWorkoutRepository: WorkoutRepository {
    typealias Entity = Workout
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getAll() -> [Workout] {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching workouts: \(error)")
            return []
        }
    }
    
    func getById(_ id: UUID) -> Workout? {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("Error fetching workout by ID: \(error)")
            return nil
        }
    }
    
    func save(_ entity: Workout) -> Workout {
        saveContext()
        return entity
    }
    
    func delete(_ entity: Workout) {
        // Preserve workout history by creating a history entry if this was a completed workout
        if entity.endTime != nil {
            preserveWorkoutHistory(entity)
        }
        
        context.delete(entity)
        saveContext()
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context in WorkoutRepository: \(error)")
            }
        }
    }
    
    func getWorkoutsForUser(_ user: User?) -> [Workout] {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        
        if let user = user {
            request.predicate = NSPredicate(format: "user == %@", user)
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching workouts for user: \(error)")
            return []
        }
    }
    
    func getWorkoutsInDateRange(_ range: DateInterval, for user: User?) -> [Workout] {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        
        var predicates: [NSPredicate] = [
            NSPredicate(format: "date >= %@ AND date <= %@", range.start as NSDate, range.end as NSDate)
        ]
        
        if let user = user {
            predicates.append(NSPredicate(format: "user == %@", user))
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching workouts in date range: \(error)")
            return []
        }
    }
    
    func createWorkout(for user: User, date: Date = Date(), name: String?, notes: String? = nil) -> Workout {
        let workout = Workout(context: context)
        workout.id = UUID()
        workout.user = user
        workout.date = date
        workout.name = name
        workout.notes = notes
        workout.startTime = nil
        workout.endTime = nil
        
        saveContext()
        return workout
    }
    
    func completeWorkout(_ workout: Workout, duration: Double) {
        workout.endTime = Date()
        workout.duration = duration
        saveContext()
    }
    
    func createWorkoutFromTemplate(_ template: Workout, for user: User) -> Workout {
        // Create a new workout
        let newWorkout = createWorkout(for: user, date: Date(), name: template.name, notes: template.notes)
        
        // Copy all sets from the template
        if let templateSets = template.sets as? Set<WorkoutSet> {
            for templateSet in templateSets {
                let newSet = WorkoutSet(context: context)
                newSet.id = UUID()
                newSet.workout = newWorkout
                newSet.exercise = templateSet.exercise
                newSet.weight = templateSet.weight
                newSet.reps = templateSet.reps
                newSet.timeSeconds = templateSet.timeSeconds
                newSet.setNumber = templateSet.setNumber
            }
        }
        
        saveContext()
        return newWorkout
    }
    
    // MARK: - Private helper methods
    
    private func preserveWorkoutHistory(_ workout: Workout) {
        // This method would create a WorkoutHistory entry to keep records
        // even after deleting the workout
        // Implementation depends on your data model
        print("Preserving workout history before deletion")
    }
} 