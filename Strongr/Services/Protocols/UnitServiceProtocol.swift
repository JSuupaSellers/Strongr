import Foundation

/// Protocol defining unit conversion and formatting operations
protocol UnitServiceProtocol {
    /// Current unit system being used
    var currentUnitSystem: UnitSystem { get }
    
    /// Set the unit system
    func setUnitSystem(_ unitSystem: UnitSystem)
    
    /// Converts weight between unit systems
    func convertWeight(_ value: Double, from fromSystem: UnitSystem, to toSystem: UnitSystem) -> Double
    
    /// Converts height between unit systems
    func convertHeight(_ value: Double, from fromSystem: UnitSystem, to toSystem: UnitSystem) -> Double
    
    /// Formats weight value with the appropriate unit
    func formatWeight(_ value: Double, in system: UnitSystem?) -> String
    
    /// Formats height value with the appropriate unit
    func formatHeight(_ value: Double, in system: UnitSystem?) -> String
    
    /// Gets the display name for the given unit system
    func displayName(for unitSystem: UnitSystem) -> String
    
    /// Gets the weight unit for the given unit system
    func weightUnit(for unitSystem: UnitSystem) -> String
    
    /// Gets the height unit for the given unit system
    func heightUnit(for unitSystem: UnitSystem) -> String
} 