import SwiftUI
import CoreData

class HomeViewModel: ObservableObject {
    // Services
    private let dataService: DataServiceProtocol
    private let statsService: StatsServiceProtocol
    private let workoutService: WorkoutServiceProtocol
    private let unitService: UnitServiceProtocol
    
    // Published properties
    @Published var workouts: [Workout] = []
    @Published var recentWorkouts: [Workout] = []
    @Published var workoutStats: WorkoutStats = WorkoutStats()
    @Published var upcomingWorkouts: [ScheduledWorkoutInfo] = []
    @Published var streakInfo: (current: Int, longest: Int) = (0, 0)
    @Published var personalRecords: [PersonalRecord] = []
    
    // Dependency injection through initializer
    init(dataService: DataServiceProtocol, statsService: StatsServiceProtocol, 
         workoutService: WorkoutServiceProtocol, unitService: UnitServiceProtocol) {
        self.dataService = dataService
        self.statsService = statsService
        self.workoutService = workoutService
        self.unitService = unitService
    }
    
    // Convenience initializer using ServiceLocator
    convenience init() {
        let serviceLocator = ServiceLocator.shared
        self.init(
            dataService: serviceLocator.dataService,
            statsService: serviceLocator.statsServiceProtocol,
            workoutService: serviceLocator.workoutService,
            unitService: serviceLocator.unitService
        )
    }
    
    func loadData() {
        guard let user = dataService.getCurrentUser() else { return }
        
        // Load workouts
        workouts = dataService.getWorkouts(for: user)
        
        // Get recent workouts (last 5)
        recentWorkouts = dataService.getRecentWorkouts(for: user, limit: 5)
        
        // Calculate workout statistics
        workoutStats = statsService.calculateWorkoutStats(for: user, workouts: workouts)
        
        // Load upcoming scheduled workouts
        upcomingWorkouts = dataService.getUpcomingScheduledWorkouts(limit: 3)
        
        // Calculate streak information
        streakInfo = statsService.calculateStreak(for: user, workouts: workouts)
        
        // Get personal records
        personalRecords = statsService.getRecentPersonalRecords(for: user, workouts: workouts)
    }
    
    // Helper method for formatting weight (used by views)
    func formatWeight(_ weight: Double) -> String {
        // Create a custom implementation that doesn't use the in parameter directly
        let targetSystem = unitService.currentUnitSystem
        let convertedValue = unitService.convertWeight(weight, from: .metric, to: targetSystem)
        return "\(String(format: "%.1f", convertedValue)) \(unitService.weightUnit(for: targetSystem))"
    }
    
    // Workout helper methods that pass through to the workout service
    func getSuggestedWorkout() -> Workout? {
        return workoutService.getSuggestedWorkout(from: recentWorkouts)
    }
    
    func getMuscleGroups(for workout: Workout) -> String? {
        return workoutService.getMuscleGroups(for: workout)
    }
    
    func startWorkout(_ workout: Workout) {
        // No need to check for user, we just need to pass the workout
        workoutService.startWorkout(workout, dataManager: getDataManager(), unitManager: getUnitManager()) 
    }
    
    func createEmptyWorkout() {
        guard let user = dataService.getCurrentUser() else { return }
        workoutService.createAndStartEmptyWorkout(for: user, dataManager: getDataManager(), unitManager: getUnitManager())
    }
    
    func showQuickSelect() {
        workoutService.showQuickSelectWorkoutDialog(
            recentWorkouts: recentWorkouts,
            dataManager: getDataManager(),
            unitManager: getUnitManager()
        )
    }
    
    // MARK: - Helper functions
    
    // These methods are temporary helpers during the transition to full service architecture
    // They allow the WorkoutService to continue functioning with the older objects
    // TODO: Update WorkoutService to use DataService and UnitService instead
    private func getDataManager() -> DataManager {
        if let dataService = dataService as? LocalDataService {
            return dataService.dataManager
        }
        // Fallback to creating a new one if needed
        return DataManager()
    }
    
    private func getUnitManager() -> UnitManager {
        // Placeholder - ideally this would be handled by updating WorkoutService
        return UnitManager.shared
    }
    
    private func getDayName(for dayOfWeek: Int16) -> String {
        let weekdaySymbols = Calendar.current.weekdaySymbols
        let index = Int(dayOfWeek - 1)
        if index >= 0 && index < weekdaySymbols.count {
            return weekdaySymbols[index]
        }
        return "Day \(dayOfWeek)"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
} 