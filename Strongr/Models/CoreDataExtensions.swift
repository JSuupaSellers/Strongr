//
//  CoreDataExtensions.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import Foundation
import CoreData
import ObjectiveC

// MARK: - Workout Extensions
extension Workout {
    // Add runtime properties for startTime and endTime
    private static var startTimeKey = "startTimeKey"
    private static var endTimeKey = "endTimeKey"
    
    var startTime: Date? {
        get {
            return objc_getAssociatedObject(self, &Workout.startTimeKey) as? Date
        }
        set {
            objc_setAssociatedObject(self, &Workout.startTimeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var endTime: Date? {
        get {
            return objc_getAssociatedObject(self, &Workout.endTimeKey) as? Date
        }
        set {
            objc_setAssociatedObject(self, &Workout.endTimeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - WorkoutSet Extensions
extension WorkoutSet {
    // Add completed property if it's missing
    private static var completedKey = "completedKey"
    
    var completed: Bool {
        get {
            return objc_getAssociatedObject(self, &WorkoutSet.completedKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &WorkoutSet.completedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - ExerciseHistory Extensions
extension ExerciseHistory {
    // Add workoutID property to track unique workouts
    private static var workoutIDKey = "workoutIDKey"
    
    var workoutID: String? {
        get {
            return objc_getAssociatedObject(self, &ExerciseHistory.workoutIDKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &ExerciseHistory.workoutIDKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
} 