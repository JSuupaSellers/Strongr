import Foundation
import SwiftUI

class LocalUnitService: UnitServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let unitSystemKey = "unitSystem"
    
    private var _unitSystem: UnitSystem = .metric
    var currentUnitSystem: UnitSystem {
        get { _unitSystem }
    }
    
    init() {
        // Load unit preference from UserDefaults
        let savedSystemValue = userDefaults.string(forKey: unitSystemKey)
        
        // Set the unit system based on saved value, defaulting to metric
        if let savedValue = savedSystemValue {
            _unitSystem = (savedValue == "metric") ? .metric : .imperial
        } else {
            _unitSystem = .metric
        }
    }
    
    func setUnitSystem(_ unitSystem: UnitSystem) {
        self._unitSystem = unitSystem
        saveUnitPreference()
    }
    
    private func saveUnitPreference() {
        userDefaults.set(_unitSystem == .metric ? "metric" : "imperial", forKey: unitSystemKey)
    }
    
    // MARK: - Conversion Methods
    
    func convertWeight(_ value: Double, from fromSystem: UnitSystem, to toSystem: UnitSystem) -> Double {
        if fromSystem == toSystem { return value }
        
        if fromSystem == .metric && toSystem == .imperial {
            // kg to lbs (1 kg = 2.20462 lbs)
            return value * 2.20462
        } else if fromSystem == .imperial && toSystem == .metric {
            // lbs to kg (1 lbs = 0.453592 kg)
            return value * 0.453592
        }
        
        return value
    }
    
    func convertHeight(_ value: Double, from fromSystem: UnitSystem, to toSystem: UnitSystem) -> Double {
        if fromSystem == toSystem { return value }
        
        if fromSystem == .metric && toSystem == .imperial {
            // cm to inches (1 cm = 0.393701 in)
            return value * 0.393701
        } else if fromSystem == .imperial && toSystem == .metric {
            // inches to cm (1 in = 2.54 cm)
            return value * 2.54
        }
        
        return value
    }
    
    // MARK: - Formatting Methods
    
    func formatWeight(_ value: Double, in system: UnitSystem? = nil) -> String {
        let targetSystem = system ?? currentUnitSystem
        let convertedValue = convertWeight(value, from: .metric, to: targetSystem)
        
        return "\(String(format: "%.1f", convertedValue)) \(weightUnit(for: targetSystem))"
    }
    
    func formatHeight(_ value: Double, in system: UnitSystem? = nil) -> String {
        let targetSystem = system ?? currentUnitSystem
        let convertedValue = convertHeight(value, from: .metric, to: targetSystem)
        
        // For imperial, show in feet and inches format
        if targetSystem == .imperial {
            let feet = Int(convertedValue / 12)
            let inches = Int(convertedValue.truncatingRemainder(dividingBy: 12))
            return "\(feet)' \(inches)\""
        } else {
            return "\(String(format: "%.1f", convertedValue)) \(heightUnit(for: targetSystem))"
        }
    }
    
    // MARK: - Unit Display Methods
    
    func displayName(for unitSystem: UnitSystem) -> String {
        switch unitSystem {
            case .metric: return "Metric"
            case .imperial: return "Imperial"
        }
    }
    
    func weightUnit(for unitSystem: UnitSystem) -> String {
        switch unitSystem {
            case .metric: return "kg"
            case .imperial: return "lbs"
        }
    }
    
    func heightUnit(for unitSystem: UnitSystem) -> String {
        switch unitSystem {
            case .metric: return "cm"
            case .imperial: return "in"
        }
    }
} 