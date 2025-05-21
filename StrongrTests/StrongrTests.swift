//
//  StrongrTests.swift
//  StrongrTests
//
//  Created by Joshua Sellers on 3/2/25.
//

import Testing
import CoreData
@testable import Strongr

struct StrongrTests {

    var persistenceController: PersistenceController!
    var managedObjectContext: NSManagedObjectContext!

    init() {
        setupInMemoryCoreDataStack()
    }

    mutating func setupInMemoryCoreDataStack() {
        persistenceController = PersistenceController(inMemory: true)
        managedObjectContext = persistenceController.container.viewContext
    }

    // Helper to create a sample User
    func createSampleUser(context: NSManagedObjectContext) -> User {
        let user = User(context: context)
        user.id = UUID()
        user.name = "Test User"
        return user
    }

    // Helper to create a sample Exercise
    func createSampleExercise(name: String = "Test Exercise", context: NSManagedObjectContext) -> Exercise {
        let exercise = Exercise(context: context)
        exercise.id = UUID()
        exercise.name = name
        exercise.category = "Strength"
        return exercise
    }

    @Test func testCreateAndSaveWorkout() async throws {
        let user = createSampleUser(context: managedObjectContext)
        
        let workout = Workout(context: managedObjectContext)
        workout.id = UUID()
        workout.name = "Morning Workout"
        workout.date = Date()
        workout.user = user

        let exercise1 = createSampleExercise(name: "Push Ups", context: managedObjectContext)
        let set1 = WorkoutSet(context: managedObjectContext)
        set1.id = UUID()
        set1.workout = workout
        set1.exercise = exercise1
        set1.reps = 10
        set1.weight = 0
        set1.setNumber = 1

        let exercise2 = createSampleExercise(name: "Squats", context: managedObjectContext)
        let set2 = WorkoutSet(context: managedObjectContext)
        set2.id = UUID()
        set2.workout = workout
        set2.exercise = exercise2
        set2.reps = 12
        set2.weight = 50
        set2.setNumber = 2
        
        workout.addToSets(set1)
        workout.addToSets(set2)

        do {
            try managedObjectContext.save()
        } catch {
            #expect(false, "Failed to save context: \(error)")
            return
        }

        let fetchedWorkout: Workout? = try {
            let request: NSFetchRequest<Workout> = Workout.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", workout.id! as CVarArg)
            request.fetchLimit = 1
            return try managedObjectContext.fetch(request).first
        }()

        #expect(fetchedWorkout != nil, "Fetched workout should not be nil")
        #expect(fetchedWorkout?.name == "Morning Workout", "Workout name mismatch")
        #expect(fetchedWorkout?.user == user, "Workout user mismatch")
        #expect(fetchedWorkout?.sets?.count == 2, "Workout should have 2 sets")

        if let sets = fetchedWorkout?.sets as? Set<WorkoutSet> {
            let sortedSets = sets.sorted { $0.setNumber < $1.setNumber }
            #expect(sortedSets.first?.exercise?.name == "Push Ups", "Set 1 exercise name mismatch")
            #expect(sortedSets.first?.reps == 10, "Set 1 reps mismatch")
            #expect(sortedSets.last?.exercise?.name == "Squats", "Set 2 exercise name mismatch")
            #expect(sortedSets.last?.reps == 12, "Set 2 reps mismatch")
        } else {
            #expect(false, "Fetched workout sets are not of type Set<WorkoutSet>")
        }
    }

    @Test func testWorkoutStartAndComplete() async throws {
        let user = createSampleUser(context: managedObjectContext)
        let workout = Workout(context: managedObjectContext)
        workout.id = UUID()
        workout.name = "Quick Test Workout"
        workout.date = Date()
        workout.user = user
        
        do {
            try managedObjectContext.save()
        } catch {
            #expect(false, "Failed to save initial workout: \(error)")
            return
        }

        // Start workout
        workout.startWorkout()
        #expect(workout.startTime != nil, "Workout startTime should be set")
        #expect(workout.endTime == nil, "Workout endTime should be nil initially")
        #expect(workout.status == .inProgress, "Workout status should be inProgress")

        do {
            try managedObjectContext.save()
        } catch {
            #expect(false, "Failed to save context after starting workout: \(error)")
            return
        }

        // Fetch and verify
        var fetchedWorkout: Workout? = try {
            let request: NSFetchRequest<Workout> = Workout.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", workout.id! as CVarArg)
            return try managedObjectContext.fetch(request).first
        }()
        #expect(fetchedWorkout?.startTime != nil, "Fetched workout startTime should be set")
        #expect(fetchedWorkout?.endTime == nil, "Fetched workout endTime should be nil after start")

        // Short delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // End workout
        workout.endWorkout() // Use the same workout instance that was fetched or the original one if properties are updated in memory correctly.
                             // For safety, re-fetch if unsure, but Workout object should update its properties.
        
        #expect(workout.endTime != nil, "Workout endTime should be set after ending")
        #expect(workout.duration > 0, "Workout duration should be greater than 0")
        #expect(workout.status == .completed, "Workout status should be completed")


        do {
            try managedObjectContext.save()
        } catch {
            #expect(false, "Failed to save context after ending workout: \(error)")
            return
        }
        
        // Fetch and verify again
        fetchedWorkout = try {
            let request: NSFetchRequest<Workout> = Workout.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", workout.id! as CVarArg)
            return try managedObjectContext.fetch(request).first
        }()
        #expect(fetchedWorkout?.endTime != nil, "Fetched workout endTime should be set")
        #expect(fetchedWorkout?.duration ?? 0 > 0, "Fetched workout duration should be > 0")
        #expect(fetchedWorkout?.status == .completed, "Fetched workout status should be .completed")
    }

    @Test func testWorkoutSetMarkCompleted() async throws {
        let user = createSampleUser(context: managedObjectContext)
        let workout = Workout(context: managedObjectContext)
        workout.id = UUID()
        workout.user = user
        
        let exercise = createSampleExercise(context: managedObjectContext)
        let workoutSet = WorkoutSet(context: managedObjectContext)
        workoutSet.id = UUID()
        workoutSet.workout = workout
        workoutSet.exercise = exercise
        workoutSet.reps = 10
        workoutSet.setNumber = 1
        workout.addToSets(workoutSet)

        #expect(workoutSet.completed == false, "WorkoutSet should initially be not completed")

        do {
            try managedObjectContext.save()
        } catch {
            #expect(false, "Failed to save context: \(error)")
            return
        }

        // Mark completed
        workoutSet.markCompleted()
        #expect(workoutSet.completed == true, "WorkoutSet 'completed' property should be true after marking")

        do {
            try managedObjectContext.save()
        } catch {
            #expect(false, "Failed to save context after marking set completed: \(error)")
            return
        }

        // Fetch and verify
        let fetchedSet: WorkoutSet? = try {
            let request: NSFetchRequest<WorkoutSet> = WorkoutSet.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", workoutSet.id! as CVarArg)
            return try managedObjectContext.fetch(request).first
        }()

        #expect(fetchedSet != nil, "Fetched set should not be nil")
        #expect(fetchedSet?.completed == true, "Fetched WorkoutSet 'completed' property should be true")
    }
    
    @Test func testDeleteWorkoutAndPreserveHistory() async throws {
        let workoutRepo = CoreDataWorkoutRepository(context: managedObjectContext)
        let user = createSampleUser(context: managedObjectContext)

        let workoutToPreserve = Workout(context: managedObjectContext)
        workoutToPreserve.id = UUID()
        let originalWorkoutID = workoutToPreserve.id!
        workoutToPreserve.name = "History Test Workout"
        let originalWorkoutName = workoutToPreserve.name
        workoutToPreserve.date = Date()
        let originalWorkoutDate = workoutToPreserve.date
        workoutToPreserve.user = user

        let exercise1 = createSampleExercise(name: "Bench Press", context: managedObjectContext)
        let set1 = WorkoutSet(context: managedObjectContext)
        set1.id = UUID()
        set1.workout = workoutToPreserve
        set1.exercise = exercise1
        set1.reps = 8
        set1.weight = 100
        set1.timeSeconds = 0
        set1.setNumber = 1
        workoutToPreserve.addToSets(set1)

        let exercise2 = createSampleExercise(name: "Deadlift", context: managedObjectContext)
        let set2 = WorkoutSet(context: managedObjectContext)
        set2.id = UUID()
        set2.workout = workoutToPreserve
        set2.exercise = exercise2
        set2.reps = 5
        set2.weight = 150
        set2.timeSeconds = 0
        set2.setNumber = 2
        workoutToPreserve.addToSets(set2)
        
        // Start and complete the workout
        workoutToPreserve.startWorkout()
        try await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        workoutToPreserve.endWorkout()
        let originalWorkoutDuration = workoutToPreserve.duration
        
        #expect(originalWorkoutDuration > 0, "Workout duration must be positive before deletion.")

        do {
            try managedObjectContext.save()
        } catch {
            #expect(false, "Failed to save workout before deletion: \(error)")
            return
        }
        
        let originalSetData = workoutToPreserve.sets?.compactMap { nsSet -> String? in
            guard let ws = nsSet as? WorkoutSet, let exName = ws.exercise?.name else { return nil }
            return "\(exName),\(ws.reps),\(ws.weight),\(ws.timeSeconds)"
        }.sorted().joined(separator: "\n") ?? ""


        // Delete the workout
        workoutRepo.delete(workoutToPreserve) // saveContext is called within delete

        // Verify Workout Deletion
        let fetchedWorkout: Workout? = try {
            let request: NSFetchRequest<Workout> = Workout.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", originalWorkoutID as CVarArg)
            return try managedObjectContext.fetch(request).first
        }()
        #expect(fetchedWorkout == nil, "Workout should be nil after deletion")

        // Verify History Preservation
        let historyRequest: NSFetchRequest<ExerciseHistory> = ExerciseHistory.fetchRequest()
        historyRequest.predicate = NSPredicate(format: "originalWorkoutID == %@", originalWorkoutID as CVarArg)
        
        let historyEntries: [ExerciseHistory] = try {
            return try managedObjectContext.fetch(historyRequest)
        }()

        #expect(historyEntries.count == 1, "Should be one history entry")
        guard let historyEntry = historyEntries.first else {
            #expect(false, "History entry is nil")
            return
        }

        #expect(historyEntry.originalWorkoutID == originalWorkoutID, "History originalWorkoutID mismatch")
        #expect(historyEntry.name == originalWorkoutName, "History name mismatch")
        // Comparing dates directly can be tricky due to precision. Compare timeIntervalSince1970.
        #expect(historyEntry.date?.timeIntervalSince1970 == originalWorkoutDate?.timeIntervalSince1970, "History date mismatch")
        #expect(historyEntry.duration == originalWorkoutDuration, "History duration mismatch")

        let historySetData = historyEntry.csvSetData?.split(separator: "\n").map(String.init).sorted().joined(separator: "\n") ?? ""
        #expect(historySetData == originalSetData, "History CSV set data mismatch. \nExpected:\n\(originalSetData)\nGot:\n\(historySetData)")
    }
}

// Helper to reset context for each test if needed, or manage in Test an init.
// For now, the struct init handles this once. If tests interfere, use @Test func setup() {}
extension StrongrTests {
    // If tests need to be isolated, this can be called in a setup method for each test
    // or the struct can be re-initialized. Swift Testing's @Test lifecycle might handle this.
    // For now, relying on the struct's init and hoping tests don't step on each other.
    // If issues arise, will need more sophisticated per-test setup/teardown.
}
