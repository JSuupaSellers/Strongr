//
//  WorkoutSet+Extensions.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import Foundation
import CoreData

/*
 Note: The 'completed' property is now a persisted property in the Core Data model.
 
 This allows us to track set completion during workouts.
*/

extension WorkoutSet {
    // Mark a set as completed during a workout session
    func markCompleted() {
        self.completed = true // This will now use the persisted 'completed' property
    }
    
    // Format weight with unit
    var formattedWeight: String {
        return String(format: "%.1f kg", weight)
    }
    
    // Format time in a human-readable way
    var formattedTime: String {
        let seconds = Int(timeSeconds)
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        if minutes > 0 {
            return "\(minutes)m \(remainingSeconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    // Determine if this set has time information
    var hasDuration: Bool {
        return timeSeconds > 0
    }
    
    // Get a concise description of the set
    var setDescription: String {
        var parts: [String] = []
        
        if weight > 0 {
            parts.append(formattedWeight)
        }
        
        if reps > 0 {
            parts.append("\(reps) reps")
        }
        
        if timeSeconds > 0 {
            parts.append(formattedTime)
        }
        
        return parts.joined(separator: " • ")
    }
} 