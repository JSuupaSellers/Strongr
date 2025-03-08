import Foundation

/// Service protocol for handling data seeding operations
protocol DataSeedingService {
    /// Check if this is the first launch of the app
    func isFirstLaunch() -> Bool
    
    /// Mark onboarding as complete
    func completeOnboarding()
    
    /// Seed default data if needed (on first launch)
    func seedDefaultDataIfNeeded()
    
    /// Force seed default data regardless of first launch status
    func forceSeedDefaultData()
} 