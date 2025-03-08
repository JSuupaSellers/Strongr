import SwiftUI
import CoreData

class ProfileViewModel: ObservableObject {
    // Services
    private let dataService: DataServiceProtocol
    private let statsService: StatsServiceProtocol
    private let unitService: UnitServiceProtocol
    
    // Published properties
    @Published var user: User?
    @Published var name: String = ""
    @Published var age: String = ""
    @Published var height: String = ""
    @Published var weight: String = ""
    @Published var workoutStats: WorkoutStats = WorkoutStats()
    
    // Computed properties
    var bmi: Double? {
        guard let user = user, user.height > 0, user.weight > 0 else { return nil }
        
        // BMI = weight (kg) / (height (m))^2
        let heightInMeters = user.height / 100
        return user.weight / (heightInMeters * heightInMeters)
    }
    
    var formattedBMI: String {
        guard let bmi = bmi else { return "Not available" }
        return String(format: "%.1f", bmi)
    }
    
    // Use dependency injection through initializer
    init(dataService: DataServiceProtocol, statsService: StatsServiceProtocol, unitService: UnitServiceProtocol) {
        self.dataService = dataService
        self.statsService = statsService
        self.unitService = unitService
    }
    
    // Convenience initializer using ServiceLocator
    convenience init() {
        let serviceLocator = ServiceLocator.shared
        self.init(
            dataService: serviceLocator.dataService,
            statsService: serviceLocator.statsServiceProtocol,
            unitService: serviceLocator.unitService
        )
    }
    
    func loadData() {
        // Load user data
        user = dataService.getCurrentUser()
        
        // Load workout stats if user exists
        if let user = user {
            let workouts = dataService.getWorkouts(for: user)
            workoutStats = statsService.calculateWorkoutStats(for: user, workouts: workouts)
        }
        
        // Initialize form fields
        name = user?.name ?? ""
        age = user?.age ?? 0 > 0 ? "\(user!.age)" : ""
        
        // Measurements are stored in metric in the database
        // For display in the form, convert to current unit system
        if let userHeight = user?.height, userHeight > 0 {
            let convertedHeight = unitService.convertHeight(userHeight, from: .metric, to: unitService.currentUnitSystem)
            height = String(format: "%.1f", convertedHeight)
        } else {
            height = ""
        }
        
        if let userWeight = user?.weight, userWeight > 0 {
            let convertedWeight = unitService.convertWeight(userWeight, from: .metric, to: unitService.currentUnitSystem)
            weight = String(format: "%.1f", convertedWeight)
        } else {
            weight = ""
        }
    }
    
    func saveProfile() {
        if let currentUser = user {
            // Update existing user
            currentUser.name = name
            
            if let ageValue = Int16(age) {
                currentUser.age = ageValue
            }
            
            // Always store values in metric in the database
            if let heightValue = Double(height) {
                let metricHeight = convertToMetric(height: heightValue)
                currentUser.height = metricHeight
            }
            
            if let weightValue = Double(weight) {
                let metricWeight = convertToMetric(weight: weightValue)
                currentUser.weight = metricWeight
            }
            
            dataService.saveContext()
        } else {
            // Create a new user if one doesn't exist
            let newUser = dataService.createUser(
                name: name,
                weight: convertToMetric(weight: Double(weight) ?? 0),
                height: convertToMetric(height: Double(height) ?? 0),
                age: Int16(age) ?? 0
            )
            user = newUser
        }
        
        // Reload data after saving
        loadData()
    }
    
    func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasLaunchedBefore")
    }
    
    // MARK: - Helper Functions
    
    private func convertToMetric(weight value: Double) -> Double {
        guard value > 0 else { return 0 }
        
        if unitService.currentUnitSystem == .imperial {
            // Convert from imperial to metric for storage
            return unitService.convertWeight(value, from: .imperial, to: .metric)
        }
        return value  // Already in metric
    }
    
    private func convertToMetric(height value: Double) -> Double {
        guard value > 0 else { return 0 }
        
        if unitService.currentUnitSystem == .imperial {
            // Convert from imperial to metric for storage
            return unitService.convertHeight(value, from: .imperial, to: .metric)
        }
        return value  // Already in metric
    }
    
    // MARK: - Formatting Methods
    
    func formatWeight(_ weight: Double) -> String {
        // Create a custom implementation that doesn't use the in parameter directly
        let targetSystem = unitService.currentUnitSystem
        let convertedValue = unitService.convertWeight(weight, from: .metric, to: targetSystem)
        return "\(String(format: "%.1f", convertedValue)) \(unitService.weightUnit(for: targetSystem))"
    }
    
    func formatHeight(_ height: Double) -> String {
        // Create a custom implementation that doesn't use the in parameter directly
        let targetSystem = unitService.currentUnitSystem
        let convertedValue = unitService.convertHeight(height, from: .metric, to: targetSystem)
        
        // For imperial, show in feet and inches format
        if targetSystem == .imperial {
            let feet = Int(convertedValue / 12)
            let inches = Int(convertedValue.truncatingRemainder(dividingBy: 12))
            return "\(feet)' \(inches)\""
        } else {
            return "\(String(format: "%.1f", convertedValue)) \(unitService.heightUnit(for: targetSystem))"
        }
    }
    
    func getCurrentUnitSystem() -> UnitSystem {
        return unitService.currentUnitSystem
    }
} 