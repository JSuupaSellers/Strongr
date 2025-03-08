import Foundation
import CoreData

/// Core Data implementation of WorkoutSetRepository
class CoreDataWorkoutSetRepository: WorkoutSetRepository {
    typealias Entity = WorkoutSet
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getAll() -> [WorkoutSet] {
        let request: NSFetchRequest<WorkoutSet> = WorkoutSet.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "workout.date", ascending: false),
            NSSortDescriptor(key: "setNumber", ascending: true)
        ]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching workout sets: \(error)")
            return []
        }
    }
    
    func getById(_ id: UUID) -> WorkoutSet? {
        let request: NSFetchRequest<WorkoutSet> = WorkoutSet.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("Error fetching workout set by ID: \(error)")
            return nil
        }
    }
    
    func save(_ entity: WorkoutSet) -> WorkoutSet {
        saveContext()
        return entity
    }
    
    func delete(_ entity: WorkoutSet) {
        context.delete(entity)
        saveContext()
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context in WorkoutSetRepository: \(error)")
            }
        }
    }
    
    func addSet(to workout: Workout, exercise: Exercise, reps: Int16?, weight: Double?, timeSeconds: Double?) -> WorkoutSet {
        // Get the next set number
        let setNumber = getNextSetNumber(for: workout, exercise: exercise)
        
        // Create the new set
        let set = WorkoutSet(context: context)
        set.id = UUID()
        set.workout = workout
        set.exercise = exercise
        set.reps = reps ?? 0
        set.weight = weight ?? 0.0
        set.timeSeconds = timeSeconds ?? 0.0
        set.setNumber = setNumber
        
        saveContext()
        return set
    }
    
    func updateSet(_ set: WorkoutSet, reps: Int16?, weight: Double?, timeSeconds: Double?) {
        if let reps = reps {
            set.reps = reps
        }
        
        if let weight = weight {
            set.weight = weight
        }
        
        if let timeSeconds = timeSeconds {
            set.timeSeconds = timeSeconds
        }
        
        saveContext()
    }
    
    func getSetsForWorkout(_ workout: Workout) -> [WorkoutSet] {
        let request: NSFetchRequest<WorkoutSet> = WorkoutSet.fetchRequest()
        request.predicate = NSPredicate(format: "workout == %@", workout)
        request.sortDescriptors = [
            NSSortDescriptor(key: "exercise.name", ascending: true),
            NSSortDescriptor(key: "setNumber", ascending: true)
        ]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching sets for workout: \(error)")
            return []
        }
    }
    
    func getSetsForExercise(_ exercise: Exercise, in workout: Workout) -> [WorkoutSet] {
        let request: NSFetchRequest<WorkoutSet> = WorkoutSet.fetchRequest()
        request.predicate = NSPredicate(format: "workout == %@ AND exercise == %@", workout, exercise)
        request.sortDescriptors = [NSSortDescriptor(key: "setNumber", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching sets for exercise in workout: \(error)")
            return []
        }
    }
    
    // MARK: - Private helper methods
    
    private func getNextSetNumber(for workout: Workout, exercise: Exercise) -> Int16 {
        let sets = getSetsForExercise(exercise, in: workout)
        if sets.isEmpty {
            return 1
        } else {
            // Find the maximum set number and add 1
            return sets.map { $0.setNumber }.max()! + 1
        }
    }
} 