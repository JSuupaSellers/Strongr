//
//  ScheduleView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/3/25.
//

import SwiftUI
import CoreData

// Add a container view for sheet presentation to avoid state issues
struct AddWorkoutSheet: View {
    // Store the dayOfWeek as a value (not a reference) to prevent state changes
    private let dayOfWeekValue: Int16
    private let scheduleValue: WorkoutSchedule
    @EnvironmentObject var dataManager: DataManager
    
    // Initialize with explicit values to prevent state sharing issues
    init(dayOfWeek: Int16, schedule: WorkoutSchedule) {
        // Validate and correct day value if needed
        if dayOfWeek < 1 || dayOfWeek > 7 {
            // If invalid day is passed, default to Monday (2)
            print("⚠️ WARNING: Invalid dayOfWeek value passed to AddWorkoutSheet: \(dayOfWeek)")
            self.dayOfWeekValue = 2 // Default to Monday
        } else {
            self.dayOfWeekValue = dayOfWeek
        }
        
        self.scheduleValue = schedule
        
        // Detailed logging for debugging
        let calendar = Calendar.current
        let weekdaySymbols = calendar.weekdaySymbols
        let dayName = dayOfWeekValue >= 1 && dayOfWeekValue <= 7 ? weekdaySymbols[Int(dayOfWeekValue) - 1] : "Invalid"
        
        print("🔍 AddWorkoutSheet initialized with:")
        print("- dayOfWeek: \(dayOfWeekValue)")
        print("- day name: \(dayName)")
    }
    
    var body: some View {
        AddScheduledWorkoutView(
            dayOfWeek: dayOfWeekValue,
            schedule: scheduleValue,
            onSave: {}
        )
        .environmentObject(dataManager)
    }
}

// New standalone component for day rows to avoid nested button issues
struct DayRowView: View {
    let date: Date
    let dayOfWeek: Int16
    let isToday: Bool
    let schedule: WorkoutSchedule
    @EnvironmentObject var dataManager: DataManager
    
    // Callbacks for actions
    let onDayTap: (Int16, Date) -> Void
    let onAddWorkout: (Int16) -> Void
    
    private let calendar = Calendar.current
    private let weekdaySymbols = Calendar.current.weekdaySymbols
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Day name header
                let dayIndex = calendar.component(.weekday, from: date) - 1
                Text(weekdaySymbols[dayIndex])
                    .font(.headline)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(isToday ? .blue : .primary)
                
                Spacer()
                
                // Add workout button - COMPLETELY SEPARATE FROM ROW BUTTON
                Button {
                    print("Add button tapped for \(weekdaySymbols[dayIndex]) (day \(dayOfWeek))")
                    onAddWorkout(dayOfWeek)
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
            }
            
            // Scheduled workouts list
            if let scheduledWorkouts = fetchScheduledWorkouts(), !scheduledWorkouts.isEmpty {
                ForEach(scheduledWorkouts, id: \.self) { scheduledWorkout in
                    HStack(spacing: 12) {
                        if let timeOfDay = scheduledWorkout.timeOfDay {
                            Text(formatTime(timeOfDay))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(width: 60, alignment: .leading)
                        } else {
                            Text("Anytime")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(width: 60, alignment: .leading)
                        }
                        
                        Text(scheduledWorkout.workout?.name ?? "Workout")
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(6)
                }
            } else {
                Text("No workouts scheduled")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .onTapGesture {
            onDayTap(dayOfWeek, date)
        }
    }
    
    private func fetchScheduledWorkouts() -> [ScheduledWorkout]? {
        let request = NSFetchRequest<ScheduledWorkout>(entityName: "ScheduledWorkout")
        request.predicate = NSPredicate(format: "schedule = %@ AND dayOfWeek = %d", schedule, dayOfWeek)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ScheduledWorkout.timeOfDay, ascending: true)]
        
        do {
            return try dataManager.context.fetch(request)
        } catch {
            print("Error fetching scheduled workouts: \(error)")
            return nil
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ScheduleView: View {
    @EnvironmentObject var dataManager: DataManager
    
    let schedule: WorkoutSchedule
    
    @State private var selectedDate = Date()
    @State private var showingAddWorkout = false
    @State private var selectedDayOfWeek: Int16 = 1
    @State private var showingDayView = false
    @State private var selectedDayDate = Date()
    @State private var showingScheduleOptions = false
    
    // Use an optional value instead - if nil, don't show sheet
    @State private var selectedDayForAddWorkout: Int16? = nil
    
    private let calendar = Calendar.current
    private let weekdaySymbols = Calendar.current.weekdaySymbols
    private let shortWeekdaySymbols = Calendar.current.shortWeekdaySymbols
    
    var currentWeekDates: [Date] {
        let today = Date()
        
        // Find the start of the week (Sunday)
        var weekdayComponents = calendar.dateComponents([.weekday], from: selectedDate)
        let weekday = weekdayComponents.weekday ?? 1
        
        // Create date for Sunday of current week
        let sundayOffset = 1 - weekday // in US calendar, weekday 1 is Sunday
        let startOfWeek = calendar.date(byAdding: .day, value: sundayOffset, to: selectedDate)!
        
        // Create array of dates for the week
        return (0..<7).map { day in
            calendar.date(byAdding: .day, value: day, to: startOfWeek)!
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Week navigation
            HStack {
                Button(action: {
                    selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate)!
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .padding()
                }
                
                Spacer()
                
                Text(weekRangeText())
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate)!
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .padding()
                }
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    let date = currentWeekDates[index]
                    let dayIndex = calendar.component(.weekday, from: date) - 1 // 0-based index for symbols array
                    let isToday = calendar.isDateInToday(date)
                    
                    VStack {
                        Text(shortWeekdaySymbols[dayIndex])
                            .font(.caption)
                            .fontWeight(isToday ? .bold : .regular)
                        
                        Text("\(calendar.component(.day, from: date))")
                            .font(.title3)
                            .fontWeight(isToday ? .bold : .regular)
                            .foregroundColor(isToday ? .blue : .primary)
                            .frame(width: 30, height: 30)
                            .background(isToday ? Color.blue.opacity(0.2) : Color.clear)
                            .clipShape(Circle())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
            
            Divider()
            
            // Weekly schedule grid
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(0..<7, id: \.self) { index in
                        // Get the actual weekday value (1-7) from the date
                        // This ensures we're using the calendar's actual weekday value
                        let date = currentWeekDates[index]
                        let dayOfWeek = Int16(calendar.component(.weekday, from: date))
                        let isToday = calendar.isDateInToday(date)
                        
                        // Verify the day value is correct for this position
                        let dayIndex = calendar.component(.weekday, from: date) - 1;
                        
                        DayRowView(
                            date: date,
                            dayOfWeek: dayOfWeek,
                            isToday: isToday,
                            schedule: schedule,
                            onDayTap: { day, date in
                                selectedDayOfWeek = day
                                selectedDayDate = date
                                showingDayView = true
                            },
                            onAddWorkout: { day in
                                selectedDayForAddWorkout = day
                                print("Setting selectedDayForAddWorkout to \(day)")
                            }
                        )
                    }
                }
                .padding()
            }
            
            // Today's workout card (only shown on current week)
            if isCurrentWeek() {
                todayWorkoutCard()
                    .padding()
            }
        }
        .navigationTitle("Workout Schedule")
        .navigationBarItems(
            trailing: Button(action: {
                showingScheduleOptions = true
            }) {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
            }
        )
        .sheet(isPresented: $showingDayView) {
            NavigationView {
                DayScheduleView(
                    dayOfWeek: selectedDayOfWeek,
                    date: selectedDayDate,
                    schedule: schedule
                )
                .environmentObject(dataManager)
            }
        }
        .actionSheet(isPresented: $showingScheduleOptions) {
            ActionSheet(
                title: Text(schedule.name ?? "Workout Schedule"),
                buttons: [
                    .default(Text("Manage Schedules")) {
                        // Navigate to schedule manager
                    },
                    .default(Text("Go to Today")) {
                        selectedDate = Date()
                    },
                    .cancel()
                ]
            )
        }
        .sheet(item: $selectedDayForAddWorkout) { day in
            // Here day is guaranteed to be non-nil
            NavigationView {
                AddWorkoutSheet(
                    dayOfWeek: day, 
                    schedule: schedule
                )
                .environmentObject(dataManager)
            }
        }
    }
    
    private func weekRangeText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let startDate = currentWeekDates[0]
        let endDate = currentWeekDates[6]
        
        let startText = formatter.string(from: startDate)
        let endText = formatter.string(from: endDate)
        
        return "\(startText) - \(endText)"
    }
    
    private func fetchScheduledWorkouts(for dayOfWeek: Int16) -> [ScheduledWorkout]? {
        let request = NSFetchRequest<ScheduledWorkout>(entityName: "ScheduledWorkout")
        request.predicate = NSPredicate(format: "schedule = %@ AND dayOfWeek = %d", schedule, dayOfWeek)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ScheduledWorkout.timeOfDay, ascending: true)]
        
        do {
            return try dataManager.context.fetch(request)
        } catch {
            print("Error fetching scheduled workouts: \(error)")
            return nil
        }
    }
    
    private func isCurrentWeek() -> Bool {
        let today = Date()
        
        let todayComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        let selectedComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)
        
        return todayComponents.yearForWeekOfYear == selectedComponents.yearForWeekOfYear &&
               todayComponents.weekOfYear == selectedComponents.weekOfYear
    }
    
    private func todayWorkoutCard() -> some View {
        let today = Date()
        let dayOfWeek = Int16(calendar.component(.weekday, from: today)) // Get actual calendar weekday
        
        return VStack {
            if let scheduledWorkouts = fetchScheduledWorkouts(for: dayOfWeek), !scheduledWorkouts.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Workout")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ForEach(scheduledWorkouts.prefix(1), id: \.self) { scheduledWorkout in
                        if let workout = scheduledWorkout.workout {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(workout.name ?? "Workout")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    
                                    if let sets = workout.sets?.allObjects as? [WorkoutSet], !sets.isEmpty {
                                        let exerciseCount = Set(sets.compactMap { $0.exercise?.name }).count
                                        let totalSets = sets.count
                                        
                                        Text("\(exerciseCount) exercises • \(totalSets) sets")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                // Separate stand-alone button
                                Button("Details") {
                                    selectedDayOfWeek = dayOfWeek
                                    selectedDayDate = today
                                    showingDayView = true
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                VStack(spacing: 12) {
                    Text("No workout scheduled for today")
                        .font(.headline)
                    
                    // Simple, standalone button
                    Button("Add Workout") {
                        // Direct action with explicit day value
                        let todayWeekday = Int16(calendar.component(.weekday, from: today))
                        print("Direct add workout from today card, day: \(todayWeekday) (\(weekdaySymbols[Int(todayWeekday) - 1])")
                        selectedDayForAddWorkout = todayWeekday
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Preview
struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let schedule = WorkoutSchedule(context: context)
        schedule.id = UUID()
        schedule.name = "Test Schedule"
        schedule.createdDate = Date()
        schedule.isActive = true
        
        return NavigationView {
            ScheduleView(schedule: schedule)
                .environmentObject(DataManager(context: context))
        }
    }
}

// Extension to make Int16 conform to Identifiable for use with sheet(item:)
extension Int16: Identifiable {
    public var id: Int16 { self }
} 
