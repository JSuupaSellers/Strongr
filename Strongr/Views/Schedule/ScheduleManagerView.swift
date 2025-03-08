//
//  ScheduleManagerView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/3/25.
//

import SwiftUI
import CoreData

struct ScheduleManagerView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    @State private var schedules: [WorkoutSchedule] = []
    @State private var showingAddSchedule = false
    @State private var newScheduleName = ""
    @State private var editingSchedule: WorkoutSchedule?
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack {
                if schedules.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                            .padding()
                        
                        Text("No Workout Schedules")
                            .font(.headline)
                        
                        Text("Create a schedule to plan your workouts")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            showingAddSchedule = true
                        }) {
                            Text("Create Schedule")
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
                } else {
                    List {
                        ForEach(schedules, id: \.self) { schedule in
                            NavigationLink(destination: ScheduleView(schedule: schedule)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(schedule.name ?? "Workout Schedule")
                                            .font(.headline)
                                        
                                        Text("Created on \(formattedDate(schedule.createdDate))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if schedule.isActive {
                                        Text("Active")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(Color.green)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    editingSchedule = schedule
                                    showingDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                if !schedule.isActive {
                                    Button {
                                        setActiveSchedule(schedule)
                                    } label: {
                                        Label("Set Active", systemImage: "checkmark.circle")
                                    }
                                    .tint(.green)
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    editingSchedule = schedule
                                    newScheduleName = schedule.name ?? ""
                                    showingAddSchedule = true
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Workout Schedules")
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(action: {
                    editingSchedule = nil
                    newScheduleName = ""
                    showingAddSchedule = true
                }) {
                    Image(systemName: "plus")
                        .font(.title3)
                }
            )
            .onAppear {
                loadSchedules()
            }
            .alert("New Schedule", isPresented: $showingAddSchedule) {
                TextField("Schedule Name", text: $newScheduleName)
                Button("Cancel", role: .cancel) { }
                Button(editingSchedule == nil ? "Create" : "Update") {
                    if let schedule = editingSchedule {
                        updateSchedule(schedule)
                    } else {
                        createNewSchedule()
                    }
                }
            } message: {
                Text(editingSchedule == nil ? "Enter a name for your new workout schedule." : "Update schedule name.")
            }
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text("Delete Schedule"),
                    message: Text("Are you sure you want to delete this schedule? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let schedule = editingSchedule {
                            deleteSchedule(schedule)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func loadSchedules() {
        let request = NSFetchRequest<WorkoutSchedule>(entityName: "WorkoutSchedule")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \WorkoutSchedule.isActive, ascending: false),
            NSSortDescriptor(keyPath: \WorkoutSchedule.createdDate, ascending: false)
        ]
        
        do {
            schedules = try dataManager.context.fetch(request)
            
            // If no active schedule and we have schedules, set the first one as active
            if !schedules.isEmpty && !schedules.contains(where: { $0.isActive }) {
                setActiveSchedule(schedules[0])
            }
        } catch {
            print("Error fetching schedules: \(error)")
        }
    }
    
    private func createNewSchedule() {
        guard !newScheduleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let schedule = WorkoutSchedule(context: dataManager.context)
        schedule.id = UUID()
        schedule.name = newScheduleName
        schedule.createdDate = Date()
        
        // If this is the first schedule, make it active
        if schedules.isEmpty || !schedules.contains(where: { $0.isActive }) {
            schedule.isActive = true
        } else {
            schedule.isActive = false
        }
        
        dataManager.saveContext()
        newScheduleName = ""
        loadSchedules()
    }
    
    private func updateSchedule(_ schedule: WorkoutSchedule) {
        guard !newScheduleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        schedule.name = newScheduleName
        dataManager.saveContext()
        newScheduleName = ""
        editingSchedule = nil
        loadSchedules()
    }
    
    private func setActiveSchedule(_ schedule: WorkoutSchedule) {
        // Deactivate all schedules
        for existingSchedule in schedules {
            existingSchedule.isActive = false
        }
        
        // Set the selected schedule as active
        schedule.isActive = true
        dataManager.saveContext()
        loadSchedules()
    }
    
    private func deleteSchedule(_ schedule: WorkoutSchedule) {
        // If this is the active schedule, we need to set another one as active
        let wasActive = schedule.isActive
        
        // Delete the schedule
        dataManager.context.delete(schedule)
        dataManager.saveContext()
        
        // Reload schedules
        loadSchedules()
        
        // If the deleted schedule was active and we have other schedules, set the first one as active
        if wasActive && !schedules.isEmpty {
            setActiveSchedule(schedules[0])
        }
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown date" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Preview
struct ScheduleManagerView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        return ScheduleManagerView()
            .environmentObject(DataManager(context: context))
    }
} 