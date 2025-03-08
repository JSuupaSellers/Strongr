import SwiftUI
import CoreData

struct UpcomingWorkoutsSection: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var unitManager: UnitManager
    var upcomingWorkouts: [ScheduledWorkoutInfo]
    private let workoutService = WorkoutService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Upcoming Workouts", icon: "calendar.badge.clock")
            
            if upcomingWorkouts.isEmpty {
                EmptyStateView(
                    message: "No upcoming scheduled workouts",
                    icon: "calendar"
                )
                
                NavigationLink(destination: navigateToSchedule()) {
                    Text("Go to Schedule")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 8)
            } else {
                ForEach(upcomingWorkouts) { scheduledWorkout in
                    VStack(alignment: .leading, spacing: 6) {
                        // Day and date header
                        HStack {
                            Text(scheduledWorkout.dayName)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                            
                            if let formattedDate = scheduledWorkout.formattedDate {
                                Text("· \(formattedDate)")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if let timeOfDay = scheduledWorkout.formattedTime {
                                Text(timeOfDay)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(6)
                            }
                        }
                        
                        // Workout details
                        if let workout = scheduledWorkout.workout {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(workout.name ?? "Workout")
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    if let sets = workout.sets?.allObjects as? [WorkoutSet], !sets.isEmpty {
                                        let exerciseCount = Set(sets.compactMap { $0.exercise?.name }).count
                                        
                                        Text("\(exerciseCount) exercises • \(sets.count) sets")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    if let workout = scheduledWorkout.workout {
                                        workoutService.startWorkout(
                                            workout, 
                                            dataManager: dataManager, 
                                            unitManager: unitManager
                                        )
                                    }
                                }) {
                                    Text("Start")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.green)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Optional notes
                        if let notes = scheduledWorkout.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.vertical, 4)
    }
    
    // MARK: - Helper functions
    
    private func navigateToSchedule() -> some View {
        // Fetch active schedule
        let scheduleRequest = NSFetchRequest<WorkoutSchedule>(entityName: "WorkoutSchedule")
        scheduleRequest.predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true))
        scheduleRequest.fetchLimit = 1
        
        do {
            let schedules = try dataManager.context.fetch(scheduleRequest)
            if let activeSchedule = schedules.first {
                return AnyView(ScheduleView(schedule: activeSchedule))
            }
        } catch {
            print("Error fetching active schedule: \(error)")
        }
        
        // If no active schedule, return the schedule manager
        return AnyView(ScheduleManagerView())
    }
} 