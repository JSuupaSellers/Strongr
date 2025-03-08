//
//  WorkoutsView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI
import CoreData

// MARK: - Workouts View
struct WorkoutsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var unitManager: UnitManager
    @Binding var currentUser: User?
    
    @State private var workouts: [Workout] = []
    @State private var showingNewWorkoutSheet = false
    
    var body: some View {
        NavigationView {
            List {
                if workouts.isEmpty {
                    Text("No workouts recorded yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(workouts) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout)
                            .environmentObject(dataManager)
                            .environmentObject(unitManager)) {
                            WorkoutRow(workout: workout)
                        }
                    }
                    .onDelete(perform: deleteWorkouts)
                }
            }
            .navigationTitle("My Workouts")
            .toolbar {
                Button(action: {
                    showingNewWorkoutSheet = true
                }) {
                    Label("Add Workout", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingNewWorkoutSheet) {
                NewWorkoutView(currentUser: currentUser, isPresented: $showingNewWorkoutSheet, onSave: {
                    loadWorkouts()
                })
            }
            .onAppear {
                loadWorkouts()
            }
        }
    }
    
    private func loadWorkouts() {
        if let user = currentUser {
            workouts = dataManager.getWorkouts(for: user)
        }
    }
    
    private func deleteWorkouts(at offsets: IndexSet) {
        for index in offsets {
            dataManager.deleteWorkout(workouts[index])
        }
        loadWorkouts()
    }
} 