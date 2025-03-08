//
//  DayScheduleView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/3/25.
//

import SwiftUI
import CoreData

struct DayScheduleView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    let dayOfWeek: Int16
    let date: Date
    let schedule: WorkoutSchedule?
    
    @State private var scheduledWorkouts: [ScheduledWorkout] = []
    @State private var showingAddWorkout = false
    @State private var selectedWorkout: ScheduledWorkout?
    @State private var showWorkoutDetails = false
    @State private var showingDeleteConfirmation = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(dateFormatter.string(from: date))
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.leading)
                
                Spacer()
                
                Button(action: {
                    showingAddWorkout = true
                }) {
                    Image(systemName: "plus")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .padding(.top)
            
            Divider()
                .padding(.vertical, 8)
            
            // Scheduled workouts
            if scheduledWorkouts.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Text("No workouts scheduled")
                        .font(.headline)
                    
                    Text("Tap the + button to add a workout")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showingAddWorkout = true
                    }) {
                        Text("Add Workout")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 12)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(scheduledWorkouts, id: \.self) { scheduledWorkout in
                        Button(action: {
                            selectedWorkout = scheduledWorkout
                            showWorkoutDetails = true
                        }) {
                            HStack(spacing: 16) {
                                if let timeOfDay = scheduledWorkout.timeOfDay {
                                    Text(timeFormatter.string(from: timeOfDay))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                        .frame(width: 80)
                                } else {
                                    Text("Anytime")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                        .frame(width: 80)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(scheduledWorkout.workout?.name ?? "Workout")
                                        .font(.headline)
                                    
                                    if let workout = scheduledWorkout.workout,
                                       let sets = workout.sets?.allObjects as? [WorkoutSet],
                                       !sets.isEmpty {
                                        let exerciseCount = Set(sets.compactMap { $0.exercise?.name }).count
                                        
                                        Text("\(exerciseCount) exercises")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if let notes = scheduledWorkout.notes, !notes.isEmpty {
                                        Text(notes)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                            .padding(.top, 2)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                selectedWorkout = scheduledWorkout
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Day Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
            }
        )
        .onAppear {
            loadScheduledWorkouts()
        }
        .sheet(isPresented: $showingAddWorkout) {
            AddScheduledWorkoutView(
                dayOfWeek: dayOfWeek,
                schedule: schedule,
                onSave: {
                    loadScheduledWorkouts()
                }
            )
            .environmentObject(dataManager)
        }
        .sheet(isPresented: $showWorkoutDetails) {
            if let workout = selectedWorkout?.workout {
                WorkoutDetailView(workout: workout)
                    .environmentObject(dataManager)
            }
        }
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("Delete Scheduled Workout"),
                message: Text("Are you sure you want to remove this workout from your schedule?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let workout = selectedWorkout {
                        deleteScheduledWorkout(workout)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func loadScheduledWorkouts() {
        guard let schedule = schedule else { return }
        
        let request = NSFetchRequest<ScheduledWorkout>(entityName: "ScheduledWorkout")
        request.predicate = NSPredicate(format: "schedule = %@ AND dayOfWeek = %d", schedule, dayOfWeek)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ScheduledWorkout.timeOfDay, ascending: true)]
        
        do {
            scheduledWorkouts = try dataManager.context.fetch(request)
        } catch {
            print("Error fetching scheduled workouts: \(error)")
        }
    }
    
    private func deleteScheduledWorkout(_ scheduledWorkout: ScheduledWorkout) {
        dataManager.context.delete(scheduledWorkout)
        dataManager.saveContext()
        loadScheduledWorkouts()
    }
}

// MARK: - Preview
struct DayScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let schedule = WorkoutSchedule(context: context)
        schedule.id = UUID()
        schedule.name = "Test Schedule"
        schedule.createdDate = Date()
        schedule.isActive = true
        
        return NavigationView {
            DayScheduleView(
                dayOfWeek: 2, // Monday
                date: Calendar.current.date(from: DateComponents(weekday: 2))!,
                schedule: schedule
            )
            .environmentObject(DataManager(context: context))
        }
    }
} 