//
//  WorkoutSet+Extensions.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import Foundation
import CoreData

/*
 Note: The 'completed' property is implemented as a runtime property
 using Objective-C associated objects (see CoreDataExtensions.swift).
 
 This allows us to track set completion during workouts without adding 
 this field to the Core Data model.
*/

extension WorkoutSet {
    // Mark a set as completed during a workout session
    func markCompleted() {
        self.completed = true
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