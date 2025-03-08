import Foundation
import CoreData

/// A service locator that provides access to app services and repositories
class ServiceLocator {
    // Singleton instance
    static let shared = ServiceLocator()
    
    // Core Data context
    private(set) var context: NSManagedObjectContext
    
    // Repositories
    private(set) var userRepository: any UserRepository
    private(set) var exerciseRepository: any ExerciseRepository
    private(set) var workoutRepository: any WorkoutRepository
    private(set) var workoutSetRepository: any WorkoutSetRepository
    
    // Services
    private(set) var dataSeedingService: any DataSeedingService
    private(set) var statsService: any StatsService
    private(set) var workoutService: WorkoutServiceProtocol
    private(set) var unitService: UnitServiceProtocol
    
    // Compatibility services for ViewModels (implements *Protocol interfaces)
    private(set) var dataService: DataServiceProtocol
    private(set) var statsServiceProtocol: StatsServiceProtocol
    
    // Private initializer to enforce singleton pattern
    private init() {
        // Get Core Data context
        context = PersistenceController.shared.container.viewContext
        
        // Initialize repositories
        userRepository = CoreDataUserRepository(context: context)
        exerciseRepository = CoreDataExerciseRepository(context: context)
        workoutRepository = CoreDataWorkoutRepository(context: context)
        workoutSetRepository = CoreDataWorkoutSetRepository(context: context)
        
        // Initialize services
        dataSeedingService = DefaultDataSeedingService(exerciseRepository: exerciseRepository)
        statsService = CoreDataStatsService(context: context, workoutRepository: workoutRepository)
        workoutService = LocalWorkoutService()
        unitService = LocalUnitService()
        
        // Initialize compatibility services for existing ViewModels
        dataService = RepositoryDataService(
            userRepository: userRepository,
            workoutRepository: workoutRepository,
            context: context
        )
        
        statsServiceProtocol = RepositoryStatsService(
            statsService: statsService,
            dataService: dataService,
            unitService: unitService
        )
        
        // Seed default data if needed
        dataSeedingService.seedDefaultDataIfNeeded()
    }
    
    // If you ever want to switch to remote implementations later:
    func useRemoteServices() {
        // This would be implemented when you have a server
        // Example: 
        // dataService = RemoteDataService(apiClient: APIClient.shared)
        // statsService = RemoteStatsService(apiClient: APIClient.shared)
        print("Remote services not yet implemented")
    }
} 