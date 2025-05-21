//
//  CoreDataModel.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import Foundation
import CoreData

/*
 This file serves as documentation for the Core Data model used in the Strongr app.
 It describes all entities, their attributes, and relationships.
 
 The actual model is defined in Strongr.xcdatamodeld.
 */

/*
 Entity: User
 Description: Represents a user of the app
 
 Attributes:
 - id: UUID
 - name: String
 - profileImageData: Binary Data (optional)
 - height: Double (optional, in cm)
 - weight: Double (optional, in kg)
 - birthdate: Date (optional)
 - gender: String (optional)
 
 Relationships:
 - workouts: Set<Workout> (to-many relationship)
 */

/*
 Entity: Workout
 Description: Represents a workout session
 
 Attributes:
 - id: UUID
 - name: String
 - date: Date
 - duration: Double (in seconds)
 - notes: String (optional)
 - startTime: Date? (Persisted: Stores the start time of the workout)
 - endTime: Date? (Persisted: Stores the end time of the workout)
 
 Relationships:
 - user: User (to-one relationship)
 - sets: Set<WorkoutSet> (to-many relationship)
 */

/*
 Entity: Exercise
 Description: Represents a type of exercise
 
 Attributes:
 - id: UUID
 - name: String
 - category: String (e.g., "Strength", "Cardio", "Flexibility")
 - targetMuscleGroup: String (optional)
 - exerciseDescription: String (optional)
 
 Relationships:
 - sets: Set<WorkoutSet> (to-many relationship)
 */

/*
 Entity: WorkoutSet
 Description: Represents a set of an exercise within a workout
 
 Attributes:
 - id: UUID
 - setNumber: Int16
 - weight: Double (in kg)
 - reps: Int16
 - timeSeconds: Double (for timed exercises)
 - completed: Boolean (Persisted: Tracks if a set was completed during a workout, defaults to false)
 
 Relationships:
 - workout: Workout (to-one relationship)
 - exercise: Exercise (to-one relationship)
 */

/*
 Entity: ExerciseHistory
 Description: Stores details of deleted workouts to preserve workout history.
 
 Attributes:
 - id: UUID (Identifier for the history entry)
 - originalWorkoutID: UUID? (ID of the Workout it came from)
 - name: String? (Name of the workout)
 - date: Date? (When the workout occurred)
 - duration: Double (Duration of the workout in seconds)
 - notes: String? (Any notes for the workout)
 - csvSetData: String? (Stores set data as a CSV-like string. Each line represents a set and contains comma-separated values for "exerciseName,reps,weight,timeSeconds".)
 
 Relationships:
 - None explicitly defined in this version. Could be related back to User if needed in future enhancements.
 */