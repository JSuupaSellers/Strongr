//
//  UnitManager.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import Foundation
import SwiftUI

/// UnitManager handles unit system preferences and conversions throughout the app
class UnitManager: ObservableObject {
    // MARK: - Unit System Enum
    
    enum UnitSystem: String, CaseIterable {
        case metric
        case imperial
        
        var displayName: String {
            switch self {
                case .metric: return "Metric"
                case .imperial: return "Imperial"
            }
        }
        
        var weightUnit: String {
            switch self {
                case .metric: return "kg"
                case .imperial: return "lbs"
            }
        }
        
        var heightUnit: String {
            switch self {
                case .metric: return "cm"
                case .imperial: return "in"
            }
        }
    }
    
    // MARK: - Published Properties
    
    @Published var unitSystem: UnitSystem = .imperial {
        didSet {
            saveUnitPreference()
        }
    }
    
    // MARK: - UserDefaults Keys
    
    private let unitSystemKey = "unitSystem"
    
    // MARK: - Singleton Instance
    
    static let shared = UnitManager()
    
    // MARK: - Initialization
    
    init() {
        // Load unit preference from UserDefaults
        if let savedSystemValue = UserDefaults.standard.string(forKey: unitSystemKey),
           let savedSystem = UnitSystem(rawValue: savedSystemValue) {
            self.unitSystem = savedSystem
        } else {
            // Default to metric
            self.unitSystem = .metric
        }
    }
    
    // MARK: - Private Methods
    
    private func saveUnitPreference() {
        UserDefaults.standard.set(unitSystem.rawValue, forKey: unitSystemKey)
    }
    
    // MARK: - Conversion Methods
    
    /// Converts weight between unit systems
    /// - Parameters:
    ///   - value: The weight value to convert
    ///   - fromSystem: The source unit system (defaults to current system)
    ///   - toSystem: The target unit system (defaults to current system)
    /// - Returns: The converted weight value
    func convertWeight(_ value: Double, from fromSystem: UnitSystem? = nil, to toSystem: UnitSystem? = nil) -> Double {
        let from = fromSystem ?? unitSystem
        let to = toSystem ?? unitSystem
        
        if from == to { return value }
        
        // Avoid using switch to ensure exhaustiveness at compile time
        if from == .metric && to == .imperial {
            // kg to lbs (1 kg = 2.20462 lbs)
            return value * 2.20462
        } else if from == .imperial && to == .metric {
            // lbs to kg (1 lbs = 0.453592 kg)
            return value * 0.453592
        }
        
        // This should never happen with the current unit systems
        // but is required to handle all possible cases
        return value
    }
    
    /// Converts height between unit systems
    /// - Parameters:
    ///   - value: The height value to convert
    ///   - fromSystem: The source unit system (defaults to current system)
    ///   - toSystem: The target unit system (defaults to current system)
    /// - Returns: The converted height value
    func convertHeight(_ value: Double, from fromSystem: UnitSystem? = nil, to toSystem: UnitSystem? = nil) -> Double {
        let from = fromSystem ?? unitSystem
        let to = toSystem ?? unitSystem
        
        if from == to { return value }
        
        // Avoid using switch to ensure exhaustiveness at compile time
        if from == .metric && to == .imperial {
            // cm to inches (1 cm = 0.393701 in)
            return value * 0.393701
        } else if from == .imperial && to == .metric {
            // inches to cm (1 in = 2.54 cm)
            return value * 2.54
        }
        
        // This should never happen with the current unit systems
        // but is required to handle all possible cases
        return value
    }
    
    /// Formats weight value with the appropriate unit
    func formatWeight(_ value: Double, in system: UnitSystem? = nil) -> String {
        let targetSystem = system ?? unitSystem
        let convertedValue = convertWeight(value, from: .metric, to: targetSystem)
        
        return "\(String(format: "%.1f", convertedValue)) \(targetSystem.weightUnit)"
    }
    
    /// Formats height value with the appropriate unit
    func formatHeight(_ value: Double, in system: UnitSystem? = nil) -> String {
        let targetSystem = system ?? unitSystem
        let convertedValue = convertHeight(value, from: .metric, to: targetSystem)
        
        // For imperial, show in feet and inches format
        if targetSystem == .imperial {
            let feet = Int(convertedValue / 12)
            let inches = Int(convertedValue.truncatingRemainder(dividingBy: 12))
            return "\(feet)' \(inches)\""
        } else {
            return "\(String(format: "%.1f", convertedValue)) \(targetSystem.heightUnit)"
        }
    }
    
    /// Formats height value in feet and inches (for imperial system only)
    func formatHeightImperial(_ centimeters: Double) -> String {
        let inches = convertHeight(centimeters, from: .metric, to: .imperial)
        let feet = Int(inches / 12)
        let remainingInches = Int(inches.truncatingRemainder(dividingBy: 12))
        
        return "\(feet)' \(remainingInches)\""
    }
} 