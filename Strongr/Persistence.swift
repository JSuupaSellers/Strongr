//
//  Persistence.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample user
        let user = User(context: viewContext)
        user.id = UUID()
        user.name = "John Doe"
        user.weight = 180.0
        user.height = 175.0
        user.age = 30
        
        // Create sample exercises
        let benchPress = Exercise(context: viewContext)
        benchPress.id = UUID()
        benchPress.name = "Bench Press"
        benchPress.category = "Strength"
        benchPress.targetMuscleGroup = "Chest"
        benchPress.exerciseDescription = "Lie on bench and press weight upward"
        
        let squat = Exercise(context: viewContext)
        squat.id = UUID()
        squat.name = "Squat"
        squat.category = "Strength"
        squat.targetMuscleGroup = "Legs"
        squat.exerciseDescription = "Bend knees with weight on shoulders"
        
        let deadlift = Exercise(context: viewContext)
        deadlift.id = UUID()
        deadlift.name = "Deadlift"
        deadlift.category = "Strength"
        deadlift.targetMuscleGroup = "Back"
        deadlift.exerciseDescription = "Lift barbell from ground to hip level"
        
        // Create sample workout
        let workout = Workout(context: viewContext)
        workout.id = UUID()
        workout.date = Date()
        workout.name = "Monday Strength Session"
        workout.duration = 60 // 60 minutes
        workout.user = user
        
        // Create sample workout sets
        let set1 = WorkoutSet(context: viewContext)
        set1.id = UUID()
        set1.reps = 10
        set1.weight = 135.0
        set1.exercise = benchPress
        set1.workout = workout
        
        let set2 = WorkoutSet(context: viewContext)
        set2.id = UUID()
        set2.reps = 8
        set2.weight = 155.0
        set2.exercise = benchPress
        set2.workout = workout
        
        let set3 = WorkoutSet(context: viewContext)
        set3.id = UUID()
        set3.reps = 8
        set3.weight = 225.0
        set3.exercise = squat
        set3.workout = workout
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Strongr")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
