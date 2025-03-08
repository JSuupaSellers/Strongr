import Foundation

/// A service locator that provides access to app services
class ServiceLocator {
    // Singleton instance
    static let shared = ServiceLocator()
    
    // Services
    private(set) var dataService: DataServiceProtocol
    private(set) var statsService: StatsServiceProtocol
    private(set) var workoutService: WorkoutServiceProtocol
    
    // Private initializer to enforce singleton pattern
    private init() {
        // Create services with dependencies
        // The order matters: dataService needs to be created first
        let dataManager = DataManager() // Using DataManager directly for now
        
        // Initialize local implementations
        dataService = LocalDataService(dataManager: dataManager)
        statsService = LocalStatsService(dataService: dataService)
        workoutService = LocalWorkoutService()
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