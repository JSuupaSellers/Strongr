//
//  NewExerciseView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI
import CoreData
import Strongr

struct NewExerciseView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var isPresented: Bool
    var onSave: ((Exercise) -> Void)?
    
    @State private var name: String = ""
    @State private var category: String = "Strength"
    @State private var targetMuscleGroup: String = ""
    @State private var exerciseDescription: String = ""
    
    private let categories = ["Strength", "Cardio", "Bodyweight", "Flexibility", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exercise Details")) {
                    TextField("Exercise Name", text: $name)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    TextField("Target Muscle Group", text: $targetMuscleGroup)
                }
                
                Section(header: Text("Description")) {
                    TextEditor(text: $exerciseDescription)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button(action: createExercise) {
                        Text("Save Exercise")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.bold)
                    }
                    .disabled(name.isEmpty)
                    .buttonStyle(BorderlessButtonStyle())
                    .foregroundColor(.white)
                    .padding()
                    .background(name.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(10)
                }
            }
            .navigationTitle("New Exercise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func createExercise() {
        let newExercise = Exercise(context: dataManager.context)
        newExercise.id = UUID()
        newExercise.name = name
        newExercise.category = category
        newExercise.targetMuscleGroup = targetMuscleGroup
        newExercise.exerciseDescription = exerciseDescription
        
        dataManager.saveContext()
        
        // Call the onSave callback with the newly created exercise
        onSave?(newExercise)
        
        isPresented = false
    }
} 