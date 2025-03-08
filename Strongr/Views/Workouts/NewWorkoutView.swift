//
//  NewWorkoutView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI
import CoreData

struct NewWorkoutView: View {
    @EnvironmentObject var dataManager: DataManager
    var currentUser: User?
    @Binding var isPresented: Bool
    var onSave: () -> Void
    
    @State private var name = ""
    @State private var notes = ""
    @State private var localUser: User?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Details")) {
                    TextField("Workout Name", text: $name)
                    
                    TextField("Notes", text: $notes)
                }
            }
            .navigationTitle("New Workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        saveWorkout()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                // Initialize local user
                if localUser == nil {
                    if let passedUser = currentUser {
                        localUser = passedUser
                    } else {
                        let users = dataManager.getUsers()
                        if let firstUser = users.first {
                            localUser = firstUser
                        } else {
                            // Create a default user if none exists
                            localUser = dataManager.createUser(
                                name: "Your Name",
                                weight: 175.0,
                                height: 180.0,
                                age: 30
                            )
                        }
                    }
                }
            }
        }
    }
    
    private func saveWorkout() {
        // Use the local user for saving the workout
        guard let user = localUser ?? currentUser else {
            // This is a fallback in case neither user is available
            let newUser = dataManager.createUser(
                name: "Your Name",
                weight: 175.0,
                height: 180.0,
                age: 30
            )
            
            _ = dataManager.createWorkout(
                for: newUser,
                date: Date(),
                name: name,
                notes: notes.isEmpty ? nil : notes
            )
            
            onSave()
            isPresented = false
            return
        }
        
        _ = dataManager.createWorkout(
            for: user,
            date: Date(),
            name: name,
            notes: notes.isEmpty ? nil : notes
        )
        
        onSave()
        isPresented = false
    }
} 