//
//  Workout+Extensions.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import Foundation
import CoreData

/*
 Note: The startTime and endTime properties are implemented as runtime properties
 using Objective-C associated objects (see CoreDataExtensions.swift).
 
 This allows us to maintain dynamic workout timing without adding these fields to the 
 Core Data model - just as the user requested.
 
 When a workout session starts, startTime is set.
 When the workout completes, endTime is set and duration is calculated.
*/

extension Workout {
    // Start a workout session
    func startWorkout() {
        self.startTime = Date()
    }
    
    // End a workout session and calculate duration
    func endWorkout() {
        let endTime = Date()
        self.endTime = endTime
        
        // Calculate duration based on start and end times
        if let startTime = self.startTime {
            let calculatedDuration = endTime.timeIntervalSince(startTime)
            self.duration = calculatedDuration
        }
    }
    
    // Computed property for workout status
    var status: WorkoutStatus {
        if let startTime = self.startTime, self.endTime == nil {
            return .inProgress
        } else if let _ = self.startTime, let _ = self.endTime {
            return .completed
        } else {
            return .planned
        }
    }
    
    // Get the total number of sets in this workout
    var setCount: Int {
        return (sets as? Set<WorkoutSet>)?.count ?? 0
    }
    
    // Get unique exercises in this workout
    var uniqueExercises: [Exercise] {
        guard let workoutSets = sets as? Set<WorkoutSet> else {
            return []
        }
        
        var exerciseSet = Set<NSManagedObjectID>()
        var exercises: [Exercise] = []
        
        for workoutSet in workoutSets {
            if let exercise = workoutSet.exercise {
                if !exerciseSet.contains(exercise.objectID) {
                    exerciseSet.insert(exercise.objectID)
                    exercises.append(exercise)
                }
            }
        }
        
        return exercises
    }
    
    // Get unique exercise count
    var uniqueExerciseCount: Int {
        return uniqueExercises.count
    }
    
    // Format workout duration as string
    var formattedDuration: String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) min"
        }
    }
}

// Workout Status Enum
enum WorkoutStatus: String {
    case planned = "Planned"
    case inProgress = "In Progress"
    case completed = "Completed"
} 