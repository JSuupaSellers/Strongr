import Foundation
import CoreData

/// Default implementation of DataSeedingService
class DefaultDataSeedingService: DataSeedingService {
    private let exerciseRepository: any ExerciseRepository
    
    init(exerciseRepository: any ExerciseRepository) {
        self.exerciseRepository = exerciseRepository
    }
    
    func isFirstLaunch() -> Bool {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        return !hasLaunchedBefore
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
    }
    
    func seedDefaultDataIfNeeded() {
        // Check if exercises already exist in the database
        let exerciseCount = exerciseRepository.getExerciseCount()
        
        // Only seed exercises if none exist and it's first launch
        if exerciseCount == 0 && isFirstLaunch() {
            seedDefaultExercises()
            print("Default exercises seeded successfully")
            completeOnboarding()
        } else {
            print("Skipping exercise seeding: \(exerciseCount) exercises already exist or not first launch")
        }
    }
    
    func forceSeedDefaultData() {
        seedDefaultExercises()
        print("Default exercises force-seeded successfully")
    }
    
    // MARK: - Private helper methods
    
    private func seedDefaultExercises() {
        // Strength Training - Chest
        _ = exerciseRepository.createExercise(
            name: "Bench Press",
            category: "Strength",
            targetMuscleGroup: "Chest",
            description: "A compound exercise that targets the chest, shoulders, and triceps."
        )
        
        _ = exerciseRepository.createExercise(
            name: "Incline Bench Press",
            category: "Strength",
            targetMuscleGroup: "Chest",
            description: "Targets the upper chest muscles with an angled bench."
        )
        
        _ = exerciseRepository.createExercise(
            name: "Decline Bench Press",
            category: "Strength",
            targetMuscleGroup: "Chest",
            description: "Targets the lower chest muscles with a declined bench."
        )
        
        _ = exerciseRepository.createExercise(
            name: "Dumbbell Fly",
            category: "Strength",
            targetMuscleGroup: "Chest",
            description: "Isolation exercise that stretches and contracts the chest muscles."
        )
        
        _ = exerciseRepository.createExercise(
            name: "Cable Crossover",
            category: "Strength",
            targetMuscleGroup: "Chest",
            description: "Isolation exercise for the chest using cable machines."
        )
        
        // Strength Training - Back
        _ = exerciseRepository.createExercise(
            name: "Deadlift",
            category: "Strength",
            targetMuscleGroup: "Back",
            description: "A compound exercise that targets the entire posterior chain."
        )
        
        _ = exerciseRepository.createExercise(
            name: "Pull-up",
            category: "Strength",
            targetMuscleGroup: "Back",
            description: "Body weight exercise targeting the upper back and biceps."
        )
        
        _ = exerciseRepository.createExercise(
            name: "Bent Over Row",
            category: "Strength",
            targetMuscleGroup: "Back",
            description: "Compound exercise targeting the middle back muscles."
        )
        
        // Add more default exercises here
        
        // Strength Training - Legs
        _ = exerciseRepository.createExercise(
            name: "Squat",
            category: "Strength",
            targetMuscleGroup: "Legs",
            description: "A compound exercise that targets the quadriceps, hamstrings, and glutes."
        )
        
        _ = exerciseRepository.createExercise(
            name: "Leg Press",
            category: "Strength",
            targetMuscleGroup: "Legs",
            description: "Machine exercise targeting the quadriceps, hamstrings, and glutes."
        )
        
        // Strength Training - Shoulders
        _ = exerciseRepository.createExercise(
            name: "Overhead Press",
            category: "Strength",
            targetMuscleGroup: "Shoulders",
            description: "Compound exercise targeting the deltoids and triceps."
        )
    }
} 