//
//  WorkoutDetailView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI
import CoreData

struct WorkoutDetailView: View {
    @EnvironmentObject private var dataManager: DataManager
    @EnvironmentObject private var unitManager: UnitManager
    @Environment(\.presentationMode) var presentationMode
    var workout: Workout
    
    // Add property to determine if view is presented modally
    var isPresentedModally: Bool = false
    
    @State private var workoutSets: [WorkoutSet] = []
    @State private var showingAddSetSheet = false
    @State private var showingEditSheet = false
    @State private var selectedSets: Set<UUID> = []
    
    @State private var name: String = ""
    @State private var notes: String = ""
    @State private var groupedSets: [String: [WorkoutSet]] = [:]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Workout header card
                workoutHeaderCard
                
                // Start workout button
                startWorkoutButton
                
                // Exercises section
                exercisesSection
                
                // Bottom padding for better spacing
                Spacer().frame(height: 20)
            }
            .padding(.horizontal)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(workout.name ?? "Workout")
        .toolbar {
            // Add a close button if presented modally
            if isPresentedModally {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // Use UIKit dismissal when presented using UIKit's modal presentation
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootViewController = windowScene.windows.first?.rootViewController {
                            rootViewController.dismiss(animated: true)
                        } else {
                            // Fallback to SwiftUI presentation mode
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Close")
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        name = workout.name ?? ""
                        notes = workout.notes ?? ""
                        showingEditSheet = true
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        showingAddSetSheet = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            if !selectedSets.isEmpty {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        deleteSets(selectedSets)
                        selectedSets.removeAll()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("\(selectedSets.count) selected")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSetSheet) {
            AddSetView(
                dataManager: _dataManager,
                workout: workout,
                isPresented: $showingAddSetSheet,
                onSave: {
                    loadWorkoutSets()
                }
            )
        }
        .sheet(isPresented: $showingEditSheet) {
            EditWorkoutView(
                workout: workout,
                name: $name,
                notes: $notes,
                isPresented: $showingEditSheet,
                dataManager: dataManager,
                onSave: {
                    loadWorkoutSets()
                }
            )
        }
        .onAppear {
            loadWorkoutSets()
        }
    }
    
    // MARK: - UI Components
    
    private var workoutHeaderCard: some View {
        VStack(spacing: 16) {
            // Metadata cards
            HStack(spacing: 12) {
                // Date card
                VStack(alignment: .leading, spacing: 6) {
                    Label("Date", systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let date = workout.date {
                        Text(dateFormatter.string(from: date))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    } else {
                        Text("Not started")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                
                // Duration card
                VStack(alignment: .leading, spacing: 6) {
                    Label("Duration", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(calculateDuration())
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
            }
            
            // Stats card
            HStack(spacing: 20) {
                // Exercise count
                statsItem(
                    value: "\(groupedSets.count)",
                    label: "EXERCISES",
                    icon: "dumbbell"
                )
                
                // Sets count
                statsItem(
                    value: "\(workoutSets.count)",
                    label: "SETS",
                    icon: "repeat"
                )
                
                // Completion
                statsItem(
                    value: "\(completedSetsPercentage)%",
                    label: "COMPLETED",
                    icon: "checkmark.circle"
                )
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
            
            // Notes card
            if let notes = workout.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Notes", systemImage: "note.text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(notes)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
            }
        }
        .padding(.top, 16)
    }
    
    private var startWorkoutButton: some View {
        NavigationLink(destination: WorkoutSessionView(workout: workout, isPresentedModally: isPresentedModally)
            .environmentObject(dataManager)
            .environmentObject(unitManager)) {
            HStack {
                Image(systemName: "play.fill")
                Text("START WORKOUT")
                    .fontWeight(.bold)
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(12)
            .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
    
    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("EXERCISES")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            if workoutSets.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "dumbbell")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.5))
                        .padding()
                    
                    Text("No exercises added yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Tap the + button to add exercises to your workout")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        showingAddSetSheet = true
                    }) {
                        Label("Add Exercise", systemImage: "plus")
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
            } else {
                ForEach(groupedSets.keys.sorted(), id: \.self) { exerciseName in
                    if let sets = groupedSets[exerciseName] {
                        exerciseCard(name: exerciseName, sets: sets)
                    }
                }
            }
        }
    }
    
    private func exerciseCard(name: String, sets: [WorkoutSet]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise header with count
            HStack {
                HStack(spacing: 12) {
                    // Exercise icon
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                        .frame(width: 24, height: 24)
                    
                    // Exercise name
                    Text(name)
                        .font(.headline)
                }
                
                Spacer()
                
                // Sets count badge
                Text("\(sets.count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue)
                    )
            }
            .padding()
            
            // Summary of set information
            HStack(spacing: 16) {
                // Weight summary (max weight)
                if let maxWeight = sets.map({ $0.weight }).max(), maxWeight > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Max Weight")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(unitManager.formatWeight(maxWeight))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Reps summary (total reps)
                let totalReps = sets.reduce(0) { $0 + $1.reps }
                if totalReps > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Reps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(totalReps)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Completion
                let completedSets = sets.filter { $0.completed }.count
                if completedSets > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(completedSets)/\(sets.count)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(completedSets == sets.count ? .green : .primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    private func statsItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func setDetailItem(value: String, unit: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(value)\(unit.isEmpty ? "" : " \(unit)")")
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }

    // MARK: - Helper Functions & Properties
    
    private var completedSetsPercentage: Int {
        if workoutSets.isEmpty {
            return 0
        }
        let completedSets = workoutSets.filter { $0.completed }.count
        return Int((Double(completedSets) / Double(workoutSets.count)) * 100)
    }
    
    private var workoutSetsHeader: some View {
        HStack {
            Text("Exercises")
            Spacer()
            if !workoutSets.isEmpty {
                Text("\(workoutSets.count) sets")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private func calculateDuration() -> String {
        guard let duration = workout.duration as? Double else {
            return "Not completed"
        }
        
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) min"
        }
    }
    
    private func loadWorkoutSets() {
        if let sets = workout.sets as? Set<WorkoutSet> {
            workoutSets = Array(sets).sorted {
                if $0.exercise?.name != $1.exercise?.name {
                    return ($0.exercise?.name ?? "") < ($1.exercise?.name ?? "")
                } else {
                    return $0.setNumber < $1.setNumber
                }
            }
            
            // Group sets by exercise name
            var grouped: [String: [WorkoutSet]] = [:]
            for set in workoutSets {
                let name = set.exercise?.name ?? "Unknown Exercise"
                if grouped[name] == nil {
                    grouped[name] = []
                }
                grouped[name]?.append(set)
            }
            
            // Sort sets within each exercise group by set number
            for key in grouped.keys {
                grouped[key]?.sort { $0.setNumber < $1.setNumber }
            }
            
            groupedSets = grouped
        }
    }
    
    private func deleteWorkoutSets(at offsets: IndexSet) {
        let setsToDelete = offsets.map { workoutSets[$0] }
        deleteSets(Set(setsToDelete.compactMap { $0.id }))
    }
    
    private func deleteSets(_ setIDs: Set<UUID>) {
        let setsToDelete = workoutSets.filter { setIDs.contains($0.id ?? UUID()) }
        
        for set in setsToDelete {
            dataManager.context.delete(set)
        }
        
        dataManager.saveContext()
        loadWorkoutSets()
    }
    
    private func toggleSetSelection(_ id: UUID?) {
        guard let id = id else { return }
        
        if selectedSets.contains(id) {
            selectedSets.remove(id)
        } else {
            selectedSets.insert(id)
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(remainingSeconds)s"
        } else {
            return "\(remainingSeconds)s"
        }
    }
}

struct EditWorkoutView: View {
    var workout: Workout
    @Binding var name: String
    @Binding var notes: String
    @Binding var isPresented: Bool
    var dataManager: DataManager
    var onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Details")) {
                    TextField("Workout Name", text: $name)
                    
                    if let date = workout.date {
                        HStack {
                            Text("Date")
                            Spacer()
                            Text(formattedDate(date))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Notes")
                        TextEditor(text: $notes)
                            .frame(minHeight: 100)
                    }
                }
            }
            .navigationTitle("Edit Workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func saveWorkout() {
        workout.name = name
        workout.notes = notes.isEmpty ? nil : notes
        
        dataManager.saveContext()
        onSave()
        isPresented = false
    }
} 

