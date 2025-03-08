//
//  AddScheduledWorkoutView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/3/25.
//

import SwiftUI
import CoreData

struct AddScheduledWorkoutView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    let dayOfWeek: Int16
    let schedule: WorkoutSchedule?
    let onSave: () -> Void
    
    // Add init specifically to log the dayOfWeek parameter
    init(dayOfWeek: Int16, schedule: WorkoutSchedule?, onSave: @escaping () -> Void) {
        self.dayOfWeek = dayOfWeek
        self.schedule = schedule
        self.onSave = onSave
        print("AddScheduledWorkoutView initialized with dayOfWeek: \(dayOfWeek)")
        
        // Calendar.current.weekdaySymbols is not optional, so access it directly
        if dayOfWeek >= 1 && dayOfWeek <= 7 {
            let weekdaySymbols = Calendar.current.weekdaySymbols
            print("Day name: \(weekdaySymbols[Int(dayOfWeek) - 1])")
        }
    }
    
    @State private var selectedWorkout: Workout?
    @State private var includeTime = false
    @State private var scheduledTime = Date()
    @State private var notes = ""
    @State private var showingWorkoutPicker = false
    
    private let calendar = Calendar.current
    private let weekdaySymbols = Calendar.current.weekdaySymbols
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Day")) {
                    Text(getDayName(for: dayOfWeek))
                        .foregroundColor(.primary)
                        .onAppear {
                            // Debug print to verify the day value received
                            print("AddWorkoutView received dayOfWeek: \(dayOfWeek) - \(getDayName(for: dayOfWeek))")
                        }
                }
                
                Section(header: Text("Workout")) {
                    if let workout = selectedWorkout {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(workout.name ?? "Workout")
                                .font(.headline)
                            
                            if let sets = workout.sets?.allObjects as? [WorkoutSet], !sets.isEmpty {
                                let exerciseCount = Set(sets.compactMap { $0.exercise?.name }).count
                                let totalSets = sets.count
                                
                                Text("\(exerciseCount) exercises • \(totalSets) sets")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        Button(action: {
                            showingWorkoutPicker = true
                        }) {
                            Text("Select Workout")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("Time")) {
                    Toggle("Schedule specific time", isOn: $includeTime)
                    
                    if includeTime {
                        DatePicker("Time", selection: $scheduledTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextField("Optional notes", text: $notes)
                        .frame(height: 80)
                }
                
                Section {
                    Button(action: saveScheduledWorkout) {
                        Text("Add to Schedule")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .background(selectedWorkout != nil ? Color.blue : Color.gray)
                            .cornerRadius(8)
                    }
                    .disabled(selectedWorkout == nil)
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Add Workout")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveScheduledWorkout()
                }
                .disabled(selectedWorkout == nil)
            )
            .sheet(isPresented: $showingWorkoutPicker) {
                WorkoutPickerView(selectedWorkout: $selectedWorkout)
            }
        }
    }
    
    private func getDayName(for dayOfWeek: Int16) -> String {
        // Calendar weekday is 1-based (1=Sunday, 2=Monday, etc.)
        // But weekdaySymbols array is 0-based (0=Sunday, 1=Monday, etc.)
        let index = Int(dayOfWeek - 1)
        if index >= 0 && index < weekdaySymbols.count {
            return weekdaySymbols[index]
        }
        return "Day \(dayOfWeek)"
    }
    
    private func saveScheduledWorkout() {
        guard let workout = selectedWorkout, let schedule = schedule else { return }
        
        let scheduledWorkout = ScheduledWorkout(context: dataManager.context)
        scheduledWorkout.id = UUID()
        scheduledWorkout.dayOfWeek = dayOfWeek
        scheduledWorkout.workout = workout
        scheduledWorkout.schedule = schedule
        scheduledWorkout.notes = notes.isEmpty ? nil : notes
        
        if includeTime {
            scheduledWorkout.timeOfDay = scheduledTime
        }
        
        dataManager.saveContext()
        onSave()
        presentationMode.wrappedValue.dismiss()
    }
}

struct WorkoutPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    @Binding var selectedWorkout: Workout?
    
    @State private var workouts: [Workout] = []
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search workouts", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // Workouts list
                List {
                    ForEach(filteredWorkouts, id: \.self) { workout in
                        Button(action: {
                            selectedWorkout = workout
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(workout.name ?? "Workout")
                                        .font(.headline)
                                    
                                    if let sets = workout.sets?.allObjects as? [WorkoutSet], !sets.isEmpty {
                                        let exerciseCount = Set(sets.compactMap { $0.exercise?.name }).count
                                        
                                        Text("\(exerciseCount) exercises")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                if selectedWorkout == workout {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .contentShape(Rectangle())
                    }
                }
            }
            .navigationBarTitle("Select Workout", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                loadWorkouts()
            }
        }
    }
    
    private var filteredWorkouts: [Workout] {
        if searchText.isEmpty {
            return workouts
        } else {
            return workouts.filter { workout in
                guard let name = workout.name else { return false }
                return name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func loadWorkouts() {
        let request = NSFetchRequest<Workout>(entityName: "Workout")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.name, ascending: true)]
        
        do {
            workouts = try dataManager.context.fetch(request)
        } catch {
            print("Error fetching workouts: \(error)")
        }
    }
}

// MARK: - Preview
struct AddScheduledWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let schedule = WorkoutSchedule(context: context)
        schedule.id = UUID()
        schedule.name = "Test Schedule"
        schedule.createdDate = Date()
        schedule.isActive = true
        
        return AddScheduledWorkoutView(
            dayOfWeek: 2, // Monday
            schedule: schedule,
            onSave: {}
        )
        .environmentObject(DataManager(context: context))
    }
} 