//
//  DataManager.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import Foundation
import CoreData
import SwiftUI

class DataManager: ObservableObject {
    public let context: NSManagedObjectContext
    
    // Singleton instance
    static let shared = DataManager()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    init() {
        self.context = PersistenceController.shared.container.viewContext
    }
    
    // MARK: - First Launch Detection
    
    // Check if this is the first launch of the app
    func isFirstLaunch() -> Bool {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        return !hasLaunchedBefore
    }
    
    // Mark onboarding as complete
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
    }
    
    // Seed default data on first launch
    func seedDefaultData() {
        // Check if exercises already exist in the database
        let exerciseCount = getExerciseCount()
        
        // Only seed exercises if none exist and it's first launch
        if exerciseCount == 0 && isFirstLaunch() {
            // Seed default exercises
            seedDefaultExercises()
            print("Default exercises seeded successfully")
        } else {
            print("Skipping exercise seeding: \(exerciseCount) exercises already exist or not first launch")
        }
    }
    
    // Get count of existing exercises
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
    
    // Seed default exercises organized by categories and muscle groups
    func seedDefaultExercises() {
        // Strength Training - Chest
        createExercise(
            name: "Bench Press",
            category: "Strength",
            targetMuscleGroup: "Chest",
            description: "A compound exercise that targets the chest, shoulders, and triceps."
        )
        createExercise(
            name: "Incline Bench Press",
            category: "Strength",
            targetMuscleGroup: "Chest",
            description: "Targets the upper chest muscles with an angled bench."
        )
        createExercise(
            name: "Decline Bench Press",
            category: "Strength",
            targetMuscleGroup: "Chest",
            description: "Targets the lower chest muscles with a declined bench."
        )
        createExercise(
            name: "Dumbbell Fly",
            category: "Strength",
            targetMuscleGroup: "Chest",
            description: "Isolation exercise that stretches and contracts the chest muscles."
        )
        createExercise(
            name: "Cable Crossover",
            category: "Strength",
            targetMuscleGroup: "Chest",
            description: "Isolation exercise for the chest using cable machines."
        )
        createExercise(
            name: "Chest Press Machine",
            category: "Machine",
            targetMuscleGroup: "Chest",
            description: "Machine-based chest press that targets the pectoral muscles."
        )
        createExercise(
            name: "Pec Deck Machine",
            category: "Machine",
            targetMuscleGroup: "Chest",
            description: "Machine that isolates the chest muscles through a controlled fly motion."
        )
        createExercise(
            name: "Smith Machine Bench Press",
            category: "Machine",
            targetMuscleGroup: "Chest",
            description: "Bench press performed on a Smith machine with a fixed bar path."
        )
        
        // Strength Training - Back
        createExercise(
            name: "Deadlift",
            category: "Strength",
            targetMuscleGroup: "Back",
            description: "A compound exercise that targets the lower back, hamstrings, and glutes."
        )
        createExercise(
            name: "Barbell Row",
            category: "Strength",
            targetMuscleGroup: "Back",
            description: "Compound exercise that targets the middle back, lats, and biceps."
        )
        createExercise(
            name: "Pull-Up",
            category: "Bodyweight",
            targetMuscleGroup: "Back",
            description: "Bodyweight exercise that targets the lats, biceps, and upper back."
        )
        createExercise(
            name: "Lat Pulldown",
            category: "Machine",
            targetMuscleGroup: "Back",
            description: "Machine exercise that targets the latissimus dorsi muscles."
        )
        createExercise(
            name: "T-Bar Row",
            category: "Strength",
            targetMuscleGroup: "Back",
            description: "Compound exercise focusing on the middle back and lats."
        )
        createExercise(
            name: "Seated Cable Row",
            category: "Machine",
            targetMuscleGroup: "Back",
            description: "Cable exercise targeting the middle back and lats with a seated position."
        )
        createExercise(
            name: "Assisted Pull-Up Machine",
            category: "Machine",
            targetMuscleGroup: "Back",
            description: "Machine that provides assistance for pull-ups, targeting the lats and upper back."
        )
        createExercise(
            name: "Back Extension Machine",
            category: "Machine",
            targetMuscleGroup: "Back",
            description: "Machine that isolates and strengthens the lower back muscles."
        )
        createExercise(
            name: "Single-Arm Dumbbell Row",
            category: "Strength",
            targetMuscleGroup: "Back",
            description: "Unilateral exercise targeting the lats and middle back."
        )
        
        // Strength Training - Legs
        createExercise(
            name: "Squat",
            category: "Strength",
            targetMuscleGroup: "Legs",
            description: "A compound exercise that targets the quadriceps, hamstrings, and glutes."
        )
        createExercise(
            name: "Leg Press",
            category: "Machine",
            targetMuscleGroup: "Legs",
            description: "Machine exercise targeting the quadriceps, hamstrings, and glutes."
        )
        createExercise(
            name: "Leg Extension",
            category: "Machine",
            targetMuscleGroup: "Legs",
            description: "Isolation exercise for the quadriceps."
        )
        createExercise(
            name: "Leg Curl",
            category: "Machine",
            targetMuscleGroup: "Legs",
            description: "Isolation exercise for the hamstrings."
        )
        createExercise(
            name: "Calf Raise",
            category: "Strength",
            targetMuscleGroup: "Legs",
            description: "Isolation exercise targeting the calf muscles."
        )
        createExercise(
            name: "Hack Squat Machine",
            category: "Machine",
            targetMuscleGroup: "Legs",
            description: "Machine that simulates a squat with back support, targeting quadriceps."
        )
        createExercise(
            name: "Smith Machine Squat",
            category: "Machine",
            targetMuscleGroup: "Legs",
            description: "Squat performed on a Smith machine with a fixed bar path."
        )
        createExercise(
            name: "Seated Calf Raise Machine",
            category: "Machine",
            targetMuscleGroup: "Legs",
            description: "Machine that isolates the soleus muscle in the calves."
        )
        createExercise(
            name: "Standing Calf Raise Machine",
            category: "Machine",
            targetMuscleGroup: "Legs",
            description: "Machine that targets the gastrocnemius muscle in the calves."
        )
        createExercise(
            name: "Leg Adductor Machine",
            category: "Machine",
            targetMuscleGroup: "Legs",
            description: "Machine targeting the inner thigh muscles."
        )
        createExercise(
            name: "Leg Abductor Machine",
            category: "Machine",
            targetMuscleGroup: "Legs",
            description: "Machine targeting the outer thigh muscles."
        )
        createExercise(
            name: "Glute Drive Machine",
            category: "Machine",
            targetMuscleGroup: "Legs",
            description: "Machine specifically designed to target the gluteal muscles."
        )
        
        // Strength Training - Shoulders
        createExercise(
            name: "Overhead Press",
            category: "Strength",
            targetMuscleGroup: "Shoulders",
            description: "Compound exercise targeting the deltoids and triceps."
        )
        createExercise(
            name: "Lateral Raise",
            category: "Strength",
            targetMuscleGroup: "Shoulders",
            description: "Isolation exercise for the lateral deltoid muscles."
        )
        createExercise(
            name: "Front Raise",
            category: "Strength",
            targetMuscleGroup: "Shoulders",
            description: "Isolation exercise for the anterior deltoid muscles."
        )
        createExercise(
            name: "Reverse Fly",
            category: "Strength",
            targetMuscleGroup: "Shoulders",
            description: "Isolation exercise for the posterior deltoid muscles."
        )
        createExercise(
            name: "Face Pull",
            category: "Strength",
            targetMuscleGroup: "Shoulders",
            description: "Exercise targeting the rear deltoids and upper back."
        )
        createExercise(
            name: "Shoulder Press Machine",
            category: "Machine",
            targetMuscleGroup: "Shoulders",
            description: "Machine that targets the deltoid muscles in a guided motion."
        )
        createExercise(
            name: "Cable Lateral Raise",
            category: "Machine",
            targetMuscleGroup: "Shoulders",
            description: "Lateral raise performed with a cable pulley for consistent tension."
        )
        createExercise(
            name: "Reverse Pec Deck",
            category: "Machine",
            targetMuscleGroup: "Shoulders",
            description: "Machine exercise targeting the rear deltoids and upper back."
        )
        createExercise(
            name: "Smith Machine Shoulder Press",
            category: "Machine",
            targetMuscleGroup: "Shoulders",
            description: "Overhead press performed on a Smith machine with a fixed bar path."
        )
        
        // Strength Training - Arms
        createExercise(
            name: "Bicep Curl",
            category: "Strength",
            targetMuscleGroup: "Arms",
            description: "Isolation exercise targeting the biceps."
        )
        createExercise(
            name: "Tricep Extension",
            category: "Strength",
            targetMuscleGroup: "Arms",
            description: "Isolation exercise targeting the triceps."
        )
        createExercise(
            name: "Hammer Curl",
            category: "Strength",
            targetMuscleGroup: "Arms",
            description: "Variation of bicep curl targeting the brachialis muscle."
        )
        createExercise(
            name: "Skull Crusher",
            category: "Strength",
            targetMuscleGroup: "Arms",
            description: "Lying tricep extension exercise."
        )
        createExercise(
            name: "Dip",
            category: "Bodyweight",
            targetMuscleGroup: "Arms",
            description: "Compound bodyweight exercise targeting triceps, chest, and shoulders."
        )
        createExercise(
            name: "Preacher Curl Machine",
            category: "Machine",
            targetMuscleGroup: "Arms",
            description: "Machine that isolates the biceps with a fixed pad for support."
        )
        createExercise(
            name: "Tricep Pushdown",
            category: "Machine",
            targetMuscleGroup: "Arms",
            description: "Cable exercise that isolates the triceps."
        )
        createExercise(
            name: "Cable Curl",
            category: "Machine",
            targetMuscleGroup: "Arms",
            description: "Bicep curl performed with a cable for consistent tension."
        )
        createExercise(
            name: "Assisted Dip Machine",
            category: "Machine",
            targetMuscleGroup: "Arms",
            description: "Machine that provides assistance for dips, targeting triceps and chest."
        )
        createExercise(
            name: "Tricep Extension Machine",
            category: "Machine",
            targetMuscleGroup: "Arms",
            description: "Machine specifically designed to isolate the triceps."
        )
        
        // Strength Training - Core
        createExercise(
            name: "Crunch",
            category: "Bodyweight",
            targetMuscleGroup: "Core",
            description: "Basic abdominal exercise."
        )
        createExercise(
            name: "Plank",
            category: "Bodyweight",
            targetMuscleGroup: "Core",
            description: "Isometric core exercise that strengthens the abdominals and lower back."
        )
        createExercise(
            name: "Russian Twist",
            category: "Bodyweight",
            targetMuscleGroup: "Core",
            description: "Exercise targeting the obliques and abdominal muscles."
        )
        createExercise(
            name: "Leg Raise",
            category: "Bodyweight",
            targetMuscleGroup: "Core",
            description: "Lower abdominal exercise."
        )
        createExercise(
            name: "Mountain Climber",
            category: "Bodyweight",
            targetMuscleGroup: "Core",
            description: "Dynamic exercise targeting core strength and cardiovascular fitness."
        )
        createExercise(
            name: "Ab Crunch Machine",
            category: "Machine",
            targetMuscleGroup: "Core",
            description: "Machine designed to target the rectus abdominis with added resistance."
        )
        createExercise(
            name: "Cable Woodchopper",
            category: "Machine",
            targetMuscleGroup: "Core",
            description: "Rotational exercise using cables to target the obliques and core."
        )
        createExercise(
            name: "Hanging Leg Raise",
            category: "Bodyweight",
            targetMuscleGroup: "Core",
            description: "Advanced core exercise performed while hanging from a bar."
        )
        createExercise(
            name: "Ab Roller",
            category: "Equipment",
            targetMuscleGroup: "Core",
            description: "Rolling device that intensely engages the entire core."
        )
        createExercise(
            name: "Decline Sit-Up Bench",
            category: "Equipment",
            targetMuscleGroup: "Core",
            description: "Angled bench that increases the difficulty of abdominal exercises."
        )
        
        // Cardio Exercises
        createExercise(
            name: "Running",
            category: "Cardio",
            targetMuscleGroup: "Full Body",
            description: "Cardiovascular exercise that engages multiple muscle groups."
        )
        createExercise(
            name: "Cycling",
            category: "Cardio",
            targetMuscleGroup: "Legs",
            description: "Low-impact cardiovascular exercise focusing on the lower body."
        )
        createExercise(
            name: "Jump Rope",
            category: "Cardio",
            targetMuscleGroup: "Full Body",
            description: "High-intensity cardio exercise that improves coordination."
        )
        createExercise(
            name: "Rowing",
            category: "Cardio",
            targetMuscleGroup: "Full Body",
            description: "Full-body cardiovascular exercise."
        )
        createExercise(
            name: "Elliptical",
            category: "Cardio",
            targetMuscleGroup: "Full Body",
            description: "Low-impact cardiovascular exercise."
        )
        createExercise(
            name: "Treadmill",
            category: "Cardio",
            targetMuscleGroup: "Legs",
            description: "Machine for walking or running in place with adjustable incline and speed."
        )
        createExercise(
            name: "Stair Climber",
            category: "Cardio",
            targetMuscleGroup: "Legs",
            description: "Cardio machine that simulates climbing stairs, targeting legs and glutes."
        )
        createExercise(
            name: "Stationary Bike",
            category: "Cardio",
            targetMuscleGroup: "Legs",
            description: "Indoor cycling machine with adjustable resistance."
        )
        createExercise(
            name: "Ski Erg",
            category: "Cardio",
            targetMuscleGroup: "Full Body",
            description: "Machine that simulates the motion of cross-country skiing."
        )
        createExercise(
            name: "Assault Bike",
            category: "Cardio",
            targetMuscleGroup: "Full Body",
            description: "Air bike with arm levers that provides full-body high-intensity cardio."
        )
        createExercise(
            name: "Jacob's Ladder",
            category: "Cardio",
            targetMuscleGroup: "Full Body",
            description: "Self-paced climbing machine that engages the entire body."
        )
        
        // Functional Training
        createExercise(
            name: "Battle Ropes",
            category: "Functional",
            targetMuscleGroup: "Full Body",
            description: "Heavy rope exercise that provides cardiovascular and muscular endurance."
        )
        createExercise(
            name: "Kettlebell Swing",
            category: "Functional",
            targetMuscleGroup: "Full Body",
            description: "Dynamic exercise using a kettlebell to target the posterior chain."
        )
        createExercise(
            name: "Medicine Ball Slam",
            category: "Functional",
            targetMuscleGroup: "Full Body",
            description: "Explosive exercise with a weighted ball to target the full body."
        )
        createExercise(
            name: "TRX Row",
            category: "Functional",
            targetMuscleGroup: "Back",
            description: "Suspension training exercise that targets the back muscles."
        )
        createExercise(
            name: "TRX Push-Up",
            category: "Functional",
            targetMuscleGroup: "Chest",
            description: "Push-up variation using suspension straps for increased instability."
        )
        createExercise(
            name: "Box Jump",
            category: "Functional",
            targetMuscleGroup: "Legs",
            description: "Plyometric exercise that builds explosive power in the lower body."
        )
        createExercise(
            name: "Sled Push",
            category: "Functional",
            targetMuscleGroup: "Full Body",
            description: "Pushing a weighted sled for power and cardiovascular conditioning."
        )
        createExercise(
            name: "Farmer's Carry",
            category: "Functional",
            targetMuscleGroup: "Full Body",
            description: "Carrying heavy weights at your sides to build grip and core strength."
        )
        
        // Save all the created exercises
        saveContext()
    }
    
    // MARK: - Save Context
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    // MARK: - User Operations
    func createUser(name: String, weight: Double?, height: Double?, age: Int16?) -> User {
        let user = User(context: context)
        user.id = UUID()
        user.name = name
        user.weight = weight ?? 0.0
        user.height = height ?? 0.0
        user.age = age ?? 0
        
        saveContext()
        return user
    }
    
    func getUsers() -> [User] {
        let request = NSFetchRequest<User>(entityName: "User")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \User.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching users: \(error)")
            return []
        }
    }
    
    func deleteUser(_ user: User) {
        context.delete(user)
        saveContext()
    }
    
    // MARK: - Exercise Operations
    func createExercise(name: String, category: String?, targetMuscleGroup: String?, description: String?) -> Exercise {
        // Check if an exercise with this name already exists
        if let existingExercise = getExerciseByName(name) {
            print("Exercise with name '\(name)' already exists, returning existing exercise")
            return existingExercise
        }
        
        // If no existing exercise was found, create a new one
        let exercise = Exercise(context: context)
        exercise.id = UUID()
        exercise.name = name
        exercise.category = category
        exercise.targetMuscleGroup = targetMuscleGroup
        exercise.exerciseDescription = description
        
        saveContext()
        return exercise
    }
    
    func getExerciseByName(_ name: String) -> Exercise? {
        let request = NSFetchRequest<Exercise>(entityName: "Exercise")
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
    
    func getExercises() -> [Exercise] {
        let request = NSFetchRequest<Exercise>(entityName: "Exercise")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching exercises: \(error)")
            return []
        }
    }
    
    func getExercises(forCategory category: String) -> [Exercise] {
        let request = NSFetchRequest<Exercise>(entityName: "Exercise")
        request.predicate = NSPredicate(format: "category == %@", category)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching exercises: \(error)")
            return []
        }
    }
    
    func getExercises(forMuscleGroup muscleGroup: String) -> [Exercise] {
        let request = NSFetchRequest<Exercise>(entityName: "Exercise")
        request.predicate = NSPredicate(format: "targetMuscleGroup == %@", muscleGroup)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching exercises: \(error)")
            return []
        }
    }
    
    func deleteExercise(_ exercise: Exercise) {
        context.delete(exercise)
        saveContext()
    }
    
    // MARK: - Workout Operations
    func createWorkout(for user: User, date: Date = Date(), name: String?, notes: String? = nil) -> Workout {
        let workout = Workout(context: context)
        workout.id = UUID()
        workout.date = date
        workout.name = name
        workout.notes = notes
        workout.user = user
        
        saveContext()
        return workout
    }
    
    func getWorkouts(for user: User?) -> [Workout] {
        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        
        if let user = user {
            fetchRequest.predicate = NSPredicate(format: "user == %@", user)
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.date, ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching workouts: \(error)")
            return []
        }
    }
    
    func completeWorkout(_ workout: Workout, duration: Double) {
        workout.duration = duration
        saveContext()
    }
    
    func deleteWorkout(_ workout: Workout) {
        // Preserve workout history before deletion
        preserveWorkoutHistory(workout)
        
        // Then delete the workout
        context.delete(workout)
        saveContext()
    }
    
    // New method to preserve workout stats before deletion
    private func preserveWorkoutHistory(_ workout: Workout) {
        guard let sets = workout.sets as? Set<WorkoutSet>,
              let date = workout.date,
              let user = workout.user else {
            return
        }
        
        // Generate a unique workout ID if one doesn't exist
        let workoutUniqueID = workout.id?.uuidString ?? UUID().uuidString
        
        for set in sets {
            guard let exercise = set.exercise else { continue }
            
            // Check if we already have a history record for this exercise on this date
            let fetchRequest: NSFetchRequest<ExerciseHistory> = ExerciseHistory.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "user == %@ AND exercise == %@ AND date == %@", 
                                               user, exercise, date as NSDate)
            
            do {
                let existingRecords = try context.fetch(fetchRequest)
                
                if let existingRecord = existingRecords.first {
                    // Update existing record if the current set is better
                    if set.weight > existingRecord.maxWeight {
                        existingRecord.maxWeight = set.weight
                        existingRecord.repsAtMaxWeight = set.reps
                    }
                    
                    // Update volume if needed
                    existingRecord.totalVolume += (set.weight * Double(set.reps))
                    existingRecord.totalSets += 1
                    
                    // Set or update the workout ID
                    existingRecord.workoutID = workoutUniqueID
                } else {
                    // Create new history record
                    let history = ExerciseHistory(context: context)
                    history.id = UUID()
                    history.user = user
                    history.exercise = exercise
                    history.date = date
                    history.maxWeight = set.weight
                    history.repsAtMaxWeight = set.reps
                    history.totalVolume = set.weight * Double(set.reps)
                    history.totalSets = 1
                    history.workoutID = workoutUniqueID // Add the workout ID
                }
            } catch {
                print("Error fetching exercise history: \(error)")
                
                // Create new history record if fetch failed
                let history = ExerciseHistory(context: context)
                history.id = UUID()
                history.user = user
                history.exercise = exercise
                history.date = date
                history.maxWeight = set.weight
                history.repsAtMaxWeight = set.reps
                history.totalVolume = set.weight * Double(set.reps)
                history.totalSets = 1
                history.workoutID = workoutUniqueID // Add the workout ID
            }
        }
        
        // Save the context after preserving all sets
        saveContext()
    }
    
    // MARK: - WorkoutSet Operations
    func addSet(to workout: Workout, exercise: Exercise, reps: Int16?, weight: Double?, timeSeconds: Double?) -> WorkoutSet {
        let workoutSet = WorkoutSet(context: context)
        workoutSet.id = UUID()
        workoutSet.reps = reps ?? 0
        workoutSet.weight = weight ?? 0.0
        workoutSet.timeSeconds = timeSeconds ?? 0.0
        workoutSet.workout = workout
        workoutSet.exercise = exercise
        
        saveContext()
        return workoutSet
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
    
    func deleteSet(_ set: WorkoutSet) {
        context.delete(set)
        saveContext()
    }
    
    func createWorkoutSet(for workout: Workout, exercise: Exercise, weight: Double, reps: Int16, timeSeconds: Double, setNumber: Int16) -> WorkoutSet {
        let workoutSet = WorkoutSet(context: context)
        workoutSet.id = UUID()
        workoutSet.workout = workout
        workoutSet.exercise = exercise
        workoutSet.weight = weight
        workoutSet.reps = reps
        workoutSet.timeSeconds = timeSeconds
        workoutSet.setNumber = setNumber
        
        saveContext()
        return workoutSet
    }
    
    // MARK: - Statistics and Analysis
    func getPersonalRecords(for user: User, exercise: Exercise) -> (maxWeight: Double, maxReps: Int16) {
        var maxWeight: Double = 0
        var maxReps: Int16 = 0
        
        // Fetch all workout sets for this exercise
        let fetchRequest: NSFetchRequest<WorkoutSet> = WorkoutSet.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "exercise == %@ AND workout.user == %@", exercise, user)
        
        do {
            let workoutSets = try context.fetch(fetchRequest)
            
            // Find max weight and max reps
            for set in workoutSets {
                if set.weight > maxWeight {
                    maxWeight = set.weight
                }
                
                if set.reps > maxReps {
                    maxReps = set.reps
                }
            }
            
        } catch {
            print("Error fetching workout sets: \(error)")
        }
        
        return (maxWeight, maxReps)
    }
    
    func getTotalVolumeLifted(for user: User, in timeRange: DateInterval? = nil) -> Double {
        var predicate: NSPredicate
        
        if let timeRange = timeRange {
            // Safely handle the DateInterval by ensuring start and end dates are valid
            let startDate = timeRange.start
            let endDate = timeRange.end
            predicate = NSPredicate(format: "workout.user == %@ AND workout.date >= %@ AND workout.date <= %@", 
                                   user, startDate as NSDate, endDate as NSDate)
        } else {
            predicate = NSPredicate(format: "workout.user == %@", user)
        }
        
        let request = NSFetchRequest<WorkoutSet>(entityName: "WorkoutSet")
        request.predicate = predicate
        
        do {
            let sets = try context.fetch(request)
            let totalVolume = sets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
            return totalVolume
        } catch {
            print("Error calculating total volume: \(error)")
            return 0.0
        }
    }
    
    func saveManagedObject(_ object: NSManagedObject) {
        saveContext()
    }
    
    // MARK: - Workout Methods
    
    func getCurrentUser() -> User? {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            print("Error fetching current user: \(error)")
            return nil
        }
    }
}

// MARK: - Preview Extension
extension DataManager {
    static var preview: DataManager {
        let manager = DataManager(context: PersistenceController.preview.container.viewContext)
        
        // Create sample data for previews
        let user = manager.createUser(name: "John Doe", weight: 75.0, height: 180.0, age: 30)
        
        // Create some exercises
        let benchPress = manager.createExercise(
            name: "Bench Press",
            category: "Strength",
            targetMuscleGroup: "Chest",
            description: "A compound exercise that targets the chest muscles, shoulders, and triceps."
        )
        
        let squat = manager.createExercise(
            name: "Squat", 
            category: "Strength", 
            targetMuscleGroup: "Legs", 
            description: "A compound exercise that targets the quadriceps, hamstrings, and glutes."
        )
        
        let pullUp = manager.createExercise(
            name: "Pull Up", 
            category: "Bodyweight", 
            targetMuscleGroup: "Back", 
            description: "An upper body exercise that targets the back, shoulders, and arms."
        )
        
        // Create a workout
        let workout = manager.createWorkout(
            for: user,
            name: "Full Body Workout"
        )
        
        // Add notes and duration manually
        workout.notes = "Felt great today!"
        workout.duration = 45 * 60 // 45 minutes in seconds
        
        // Add some workout sets using addSet method
        let set1 = manager.addSet(
            to: workout,
            exercise: benchPress,
            reps: 10,
            weight: 80.0,
            timeSeconds: 0
        )
        
        let set2 = manager.addSet(
            to: workout,
            exercise: benchPress,
            reps: 8,
            weight: 85.0,
            timeSeconds: 0
        )
        
        let set3 = manager.addSet(
            to: workout,
            exercise: squat,
            reps: 12,
            weight: 100.0,
            timeSeconds: 0
        )
        
        // Create an older workout with a past date
        let oldDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let oldWorkout = manager.createWorkout(
            for: user,
            date: oldDate,
            name: "Upper Body"
        )
        
        // Add notes and duration manually
        oldWorkout.notes = "Quick session"
        oldWorkout.duration = 30 * 60 // 30 minutes in seconds
        
        let set4 = manager.addSet(
            to: oldWorkout,
            exercise: pullUp,
            reps: 12,
            weight: 0,
            timeSeconds: 0
        )
        
        // Save the context
        try? manager.context.save()
        
        return manager
    }
} 