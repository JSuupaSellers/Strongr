import SwiftUI
import CoreData

class HomeViewModel: ObservableObject {
    // Services
    private var dataService: DataServiceProtocol
    private var statsService: StatsServiceProtocol
    private var workoutService: WorkoutServiceProtocol
    
    // DataManager and UnitManager (kept for backward compatibility)
    private var dataManager: DataManager?
    private var unitManager: UnitManager?
    
    // Published properties
    @Published var workouts: [Workout] = []
    @Published var recentWorkouts: [Workout] = []
    @Published var workoutStats: WorkoutStats = WorkoutStats()
    @Published var upcomingWorkouts: [ScheduledWorkoutInfo] = []
    @Published var streakInfo: (current: Int, longest: Int) = (0, 0)
    @Published var personalRecords: [HomeViewModel.PersonalRecord] = []
    
    // Personal record data structure
    struct PersonalRecord: Identifiable {
        let id = UUID()
        let exerciseName: String
        let weight: Double
        let reps: Int16
        let date: Date
    }
    
    init() {
        // Get services from service locator
        let serviceLocator = ServiceLocator.shared
        self.dataService = serviceLocator.dataService
        self.statsService = serviceLocator.statsService
        self.workoutService = serviceLocator.workoutService
    }
    
    // For backward compatibility with existing views
    func setupWith(dataManager: DataManager, unitManager: UnitManager) {
        self.dataManager = dataManager
        self.unitManager = unitManager
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
        
        // Get personal records and convert to our local type
        let serviceRecords = statsService.getRecentPersonalRecords(for: user, workouts: workouts)
        personalRecords = serviceRecords.map { record in
            return PersonalRecord(
                exerciseName: record.exerciseName,
                weight: record.weight,
                reps: record.reps,
                date: record.date
            )
        }
    }
    
    // Helper method for formatting weight (used by views)
    func formatWeight(_ weight: Double) -> String {
        guard let unitManager = unitManager else {
            // If unitManager is not set, use a default format
            return String(format: "%.1f", weight)
        }
        
        // Convert UnitManager.UnitSystem to the service's UnitSystem
        let serviceUnitSystem: UnitSystem = unitManager.unitSystem == .metric ? .metric : .imperial
        return statsService.formatWeight(weight, unitSystem: serviceUnitSystem)
    }
    
    // Workout helper methods that pass through to the workout service
    func getSuggestedWorkout() -> Workout? {
        return workoutService.getSuggestedWorkout(from: recentWorkouts)
    }
    
    func getMuscleGroups(for workout: Workout) -> String? {
        return workoutService.getMuscleGroups(for: workout)
    }
    
    func startWorkout(_ workout: Workout) {
        guard let dataManager = dataManager, let unitManager = unitManager else {
            print("Error: DataManager or UnitManager not set up")
            return
        }
        
        workoutService.startWorkout(workout, dataManager: dataManager, unitManager: unitManager)
    }
    
    func createEmptyWorkout() {
        guard let dataManager = dataManager, 
              let unitManager = unitManager,
              let user = dataService.getCurrentUser() else {
            print("Error: Missing required dependencies")
            return
        }
        
        workoutService.createAndStartEmptyWorkout(for: user, dataManager: dataManager, unitManager: unitManager)
    }
    
    func showQuickSelect() {
        guard let dataManager = dataManager, let unitManager = unitManager else {
            print("Error: DataManager or UnitManager not set up")
            return
        }
        
        workoutService.showQuickSelectWorkoutDialog(
            recentWorkouts: recentWorkouts,
            dataManager: dataManager,
            unitManager: unitManager
        )
    }
    
    // MARK: - Helper functions
    
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