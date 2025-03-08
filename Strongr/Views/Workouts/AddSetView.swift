//
//  AddSetView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI
import CoreData
import Strongr

struct AddSetView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var unitManager: UnitManager
    var workout: Workout
    @Binding var isPresented: Bool
    var onSave: () -> Void
    
    @State private var selectedExercise: Exercise?
    @State private var showingExercisePicker = false
    @State private var weight: String = ""
    @State private var reps: String = ""
    @State private var timeSeconds: String = ""
    @State private var setNumber: Int16 = 1
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exercise")) {
                    if let exercise = selectedExercise {
                        HStack {
                            Text(exercise.name ?? "Selected Exercise")
                            Spacer()
                            Button("Change") {
                                showingExercisePicker = true
                            }
                        }
                    } else {
                        Button("Select Exercise") {
                            showingExercisePicker = true
                        }
                    }
                }
                
                if selectedExercise != nil {
                    Section(header: Text("Set Details")) {
                        HStack {
                            Text("Set #")
                            Spacer()
                            Text("\(setNumber)")
                            Stepper("", value: $setNumber, in: 1...20)
                                .labelsHidden()
                        }
                        .padding(.vertical, 4)
                        
                        Text("Set number indicates which set in the sequence this is for the selected exercise.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 8)
                        
                        TextField("Weight (\(unitManager.unitSystem.weightUnit))", text: $weight)
                            .keyboardType(.decimalPad)
                        
                        TextField("Reps", text: $reps)
                            .keyboardType(.numberPad)
                        
                        TextField("Time (seconds)", text: $timeSeconds)
                            .keyboardType(.numberPad)
                    }
                    
                    Button(action: saveWorkoutSet) {
                        Text("Save Set")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.bold)
                    }
                    .disabled(selectedExercise == nil || (weight.isEmpty && reps.isEmpty && timeSeconds.isEmpty))
                    .buttonStyle(BorderlessButtonStyle())
                    .foregroundColor(.white)
                    .padding()
                    .background(selectedExercise == nil || (weight.isEmpty && reps.isEmpty && timeSeconds.isEmpty) ? Color.gray : Color.blue)
                    .cornerRadius(10)
                    .padding()
                }
            }
            .navigationTitle("Add Exercise Set")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView(
                    selectedExercise: $selectedExercise,
                    isPresented: $showingExercisePicker
                )
            }
        }
    }
    
    private func saveWorkoutSet() {
        guard let exercise = selectedExercise else { return }
        
        let workoutSet = WorkoutSet(context: dataManager.context)
        workoutSet.id = UUID()
        workoutSet.exercise = exercise
        workoutSet.workout = workout
        workoutSet.setNumber = setNumber
        
        if let weightValue = Double(weight), weightValue > 0 {
            if unitManager.unitSystem == .imperial {
                workoutSet.weight = unitManager.convertWeight(weightValue, from: .imperial, to: .metric)
            } else {
                workoutSet.weight = weightValue
            }
        }
        
        if let repsValue = Int16(reps) {
            workoutSet.reps = repsValue
        }
        
        if let timeValue = Double(timeSeconds) {
            workoutSet.timeSeconds = timeValue
        }
        
        dataManager.saveContext()
        onSave()
        isPresented = false
    }
}

