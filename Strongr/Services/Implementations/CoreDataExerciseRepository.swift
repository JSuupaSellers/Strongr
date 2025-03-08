import Foundation
import CoreData

/// Core Data implementation of ExerciseRepository
class CoreDataExerciseRepository: ExerciseRepository {
    typealias Entity = Exercise
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getAll() -> [Exercise] {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching exercises: \(error)")
            return []
        }
    }
    
    func getById(_ id: UUID) -> Exercise? {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("Error fetching exercise by ID: \(error)")
            return nil
        }
    }
    
    func save(_ entity: Exercise) -> Exercise {
        saveContext()
        return entity
    }
    
    func delete(_ entity: Exercise) {
        context.delete(entity)
        saveContext()
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context in ExerciseRepository: \(error)")
            }
        }
    }
    
    func getExerciseByName(_ name: String) -> Exercise? {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("Error fetching exercise by name: \(error)")
            return nil
        }
    }
    
    func getExercisesByCategory(_ category: String) -> [Exercise] {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching exercises by category: \(error)")
            return []
        }
    }
    
    func getExercisesByMuscleGroup(_ muscleGroup: String) -> [Exercise] {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "targetMuscleGroup == %@", muscleGroup)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching exercises by muscle group: \(error)")
            return []
        }
    }
    
    func createExercise(name: String, category: String?, targetMuscleGroup: String?, description: String?) -> Exercise {
        let exercise = Exercise(context: context)
        exercise.id = UUID()
        exercise.name = name
        exercise.category = category
        exercise.targetMuscleGroup = targetMuscleGroup
        exercise.exerciseDescription = description
        
        saveContext()
        return exercise
    }
    
    func getExerciseCount() -> Int {
        let request = NSFetchRequest<Exercise>(entityName: "Exercise")
        request.resultType = .countResultType
        
        do {
            let countResult = try context.fetch(request) as! [NSNumber]
            return countResult.first?.intValue ?? 0
        } catch {
            print("Error counting exercises: \(error)")
            return 0
        }
    }
} 