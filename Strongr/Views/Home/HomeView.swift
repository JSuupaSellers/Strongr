//
//  HomeView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI
import CoreData
import Charts

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var unitManager: UnitManager
    @State private var workouts: [Workout] = []
    @State private var recentWorkouts: [Workout] = []
    @State private var workoutStats: WorkoutStats = WorkoutStats()
    @State private var upcomingWorkouts: [ScheduledWorkoutInfo] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Welcome message
                welcomeSection
                
                // Today's Workout / Quick Start section
                todayWorkoutSection
                
                // Upcoming scheduled workouts
                upcomingWorkoutsSection
                
                // Recent workouts
                recentWorkoutsSection
                
                // Recent achievements
                achievementsSection
                
                // Mini stats with link to full stats
                miniStatsSection
            }
            .padding(.horizontal)
        }
        .background(Color(.systemGray6).opacity(0.5))
        .navigationTitle("Dashboard")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ProfileView()) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 22))
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .onAppear {
            loadData()
        }
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let user = dataManager.getCurrentUser() {
                Text("Welcome back, \(user.name ?? "Athlete")!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Let's crush today's workout!")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            } else {
                Text("Welcome to Strongr!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                
                Text("Start tracking your fitness journey")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.vertical, 4)
    }
    
    private var todayWorkoutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Today's Workout", icon: "flame.fill")
            
            VStack(spacing: 16) {
                // Quick start buttons
                HStack(spacing: 12) {
                    Button(action: {
                        createEmptyWorkout()
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                            
                            Text("New Workout")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.8), .blue]), startPoint: .top, endPoint: .bottom))
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // Show quick select of recent workouts to repeat
                        showQuickSelect()
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                            
                            Text("Repeat Workout")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(gradient: Gradient(colors: [.green.opacity(0.8), .green]), startPoint: .top, endPoint: .bottom))
                        .cornerRadius(12)
                    }
                }
                
                // Suggested workout based on recent activity
                if let suggestedWorkout = getSuggestedWorkout() {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Suggested for Today")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(suggestedWorkout.name ?? "Workout")
                                    .font(.headline)
                                
                                if let muscleGroups = getMuscleGroups(for: suggestedWorkout) {
                                    Text(muscleGroups)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                startWorkout(suggestedWorkout)
                            }) {
                                Text("Start")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.7))
                        .cornerRadius(12)
                    }
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
    
    private var upcomingWorkoutsSection: some View {
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
                                        startWorkout(workout)
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
    
    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SectionHeader(title: "Recent Workouts", icon: "clock.arrow.circlepath")
                
                Spacer()
                
                NavigationLink(destination: WorkoutsListView()) {
                    Text("View All")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.blue)
                }
            }
            
            if recentWorkouts.isEmpty {
                EmptyStateView(
                    message: "No recent workouts",
                    icon: "figure.run"
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(recentWorkouts.prefix(3)) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout)
                            .environmentObject(dataManager)
                            .environmentObject(unitManager)) {
                            HomeWorkoutCard(workout: workout, unitManager: unitManager)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
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
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Your Achievements", icon: "trophy.fill")
            
            VStack(spacing: 16) {
                // Current streak
                let streakInfo = calculateStreak()
                
                HStack(spacing: 16) {
                    VStack(alignment: .center, spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.orange.opacity(0.7), .orange]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: "flame.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Current Streak")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Spacer()
                            
                            Text("\(streakInfo.current) days")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.orange)
                        }
                        
                        if streakInfo.current > 0 {
                            Text("You're on fire! Keep the momentum going.")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        } else {
                            Text("Start a new streak today!")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(12)
                
                // Recent personal records
                if let recentPRs = getRecentPersonalRecords(), !recentPRs.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Personal Records")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.leading, 4)
                        
                        VStack(spacing: 10) {
                            ForEach(recentPRs.prefix(2), id: \.id) { pr in
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    
                                    Text("\(pr.exerciseName)")
                                        .font(.system(size: 15, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Text("\(formatWeight(pr.weight)) × \(pr.reps) reps")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.blue)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6).opacity(0.3))
                                .cornerRadius(8)
                            }
                        }
                    }
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
    
    private var miniStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SectionHeader(title: "Quick Stats", icon: "chart.bar.fill")
                
                Spacer()
                
                NavigationLink(destination: StatsView()) {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.blue)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Two most important stats
            HStack(spacing: 16) {
                // Current streak
                VStack(alignment: .center, spacing: 12) {
                    Text("Current Streak")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .center, spacing: 4) {
                        Text("\(workoutStats.currentStreak)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("days")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(12)
                
                // Workout count
                VStack(alignment: .center, spacing: 12) {
                    Text("Workouts")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("\(workoutStats.totalWorkouts)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.green)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(12)
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
    
    private func loadData() {
        guard let user = dataManager.getCurrentUser() else { return }
        
        // Load workouts
        workouts = dataManager.getWorkouts(for: user)
        
        // Recent workouts (last 5, sorted by date desc)
        recentWorkouts = workouts.sorted { workout1, workout2 in
            guard let date1 = workout1.date, let date2 = workout2.date else { return false }
            return date1 > date2
        }.prefix(5).map { $0 }
        
        // Calculate stats
        calculateWorkoutStats()
        
        // Load upcoming scheduled workouts
        loadUpcomingWorkouts()
    }
    
    private func calculateWorkoutStats() {
        var stats = WorkoutStats()
        
        // Total workouts
        stats.totalWorkouts = workouts.count
        
        // This week's workouts
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        
        stats.workoutsThisWeek = workouts.filter { workout in
            guard let date = workout.date else { return false }
            return date >= startOfWeek
        }.count
        
        // Total duration
        stats.totalDuration = workouts.reduce(0) { $0 + ($1.duration) }
        
        // Total sets
        stats.totalSets = workouts.reduce(0) { total, workout in
            guard let sets = workout.sets as? Set<WorkoutSet> else { return total }
            return total + sets.count
        }
        
        // Unique exercises
        var exerciseIDs = Set<NSManagedObjectID>()
        for workout in workouts {
            guard let sets = workout.sets as? Set<WorkoutSet> else { continue }
            for set in sets {
                if let exercise = set.exercise {
                    exerciseIDs.insert(exercise.objectID)
                }
            }
        }
        stats.uniqueExercises = exerciseIDs.count
        
        // Current streak
        stats.currentStreak = calculateCurrentStreak()
        
        // Workout consistency (workouts per week over the last month)
        if !workouts.isEmpty {
            let monthAgo = calendar.date(byAdding: .day, value: -30, to: today) ?? today
            let workoutsLastMonth = workouts.filter { workout in
                guard let date = workout.date else { return false }
                return date >= monthAgo
            }
            
            if !workoutsLastMonth.isEmpty {
                // Instead of unique workout days, let's calculate the average number of workouts per week
                let numberOfWorkouts = workoutsLastMonth.count
                let daysBetween = max(1, calendar.dateComponents([.day], from: monthAgo, to: today).day ?? 30)
                stats.consistency = Double(numberOfWorkouts) / (Double(daysBetween) / 7.0)
            }
        }
        
        workoutStats = stats
    }
    
    private func getWeeklyData() -> [WeeklyActivityItem] {
        let calendar = Calendar.current
        let today = Date()
        var result: [WeeklyActivityItem] = []
        
        // Get start of current week
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return []
        }
        
        // Format for day names
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "E"
        
        // Create array with each day of week
        for dayOffset in 0..<7 {
            guard let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else { continue }
            
            // Count sets for this day
            let setsCount = workouts.reduce(0) { count, workout in
                guard let workoutDate = workout.date,
                      calendar.isDate(workoutDate, inSameDayAs: dayDate),
                      let sets = workout.sets as? Set<WorkoutSet> else {
                    return count
                }
                return count + sets.count
            }
            
            let dayName = dayFormatter.string(from: dayDate)
            result.append(WeeklyActivityItem(day: dayName, sets: setsCount))
        }
        
        return result
    }
    
    private func formatTotalTime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) min"
        }
    }
    
    private func loadUpcomingWorkouts() {
        // Fetch active schedule
        let scheduleRequest = NSFetchRequest<WorkoutSchedule>(entityName: "WorkoutSchedule")
        scheduleRequest.predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true))
        scheduleRequest.fetchLimit = 1
        
        do {
            let schedules = try dataManager.context.fetch(scheduleRequest)
            guard let activeSchedule = schedules.first else { return }
            
            // Get current date info
            let today = Date()
            let calendar = Calendar.current
            let currentWeekday = calendar.component(.weekday, from: today) // 1 = Sunday, 2 = Monday, etc.
            
            // Fetch next 3 days of scheduled workouts
            var upcomingInfo: [ScheduledWorkoutInfo] = []
            
            for dayOffset in 0..<5 {
                // Calculate the actual date for this weekday
                var dateComponent = DateComponents()
                dateComponent.day = dayOffset
                let targetDate = calendar.date(byAdding: dateComponent, to: today)!
                
                // Get the weekday of the target date
                let targetWeekday = calendar.component(.weekday, from: targetDate)
                let dayOfWeek = Int16(targetWeekday)
                
                // Fetch scheduled workouts for this day
                let workoutRequest = NSFetchRequest<ScheduledWorkout>(entityName: "ScheduledWorkout")
                workoutRequest.predicate = NSPredicate(format: "schedule = %@ AND dayOfWeek = %d", activeSchedule, dayOfWeek)
                workoutRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ScheduledWorkout.timeOfDay, ascending: true)]
                
                if let scheduledWorkouts = try? dataManager.context.fetch(workoutRequest), !scheduledWorkouts.isEmpty {
                    for scheduledWorkout in scheduledWorkouts {
                        let info = ScheduledWorkoutInfo(
                            id: scheduledWorkout.id ?? UUID(),
                            dayOfWeek: scheduledWorkout.dayOfWeek,
                            dayName: getDayName(for: scheduledWorkout.dayOfWeek),
                            date: targetDate,
                            formattedDate: formatDate(targetDate),
                            timeOfDay: scheduledWorkout.timeOfDay,
                            formattedTime: scheduledWorkout.timeOfDay != nil ? formatTime(scheduledWorkout.timeOfDay!) : nil,
                            workout: scheduledWorkout.workout,
                            notes: scheduledWorkout.notes
                        )
                        upcomingInfo.append(info)
                    }
                }
                
                // If we have 3 workouts, stop looking for more
                if upcomingInfo.count >= 3 {
                    break
                }
            }
            
            self.upcomingWorkouts = upcomingInfo
        } catch {
            print("Error fetching scheduled workouts: \(error)")
        }
    }
    
    private func getDayName(for dayOfWeek: Int16) -> String {
        let weekdaySymbols = Calendar.current.weekdaySymbols
        let index = Int(dayOfWeek - 1)
        if index >= 0 && index < weekdaySymbols.count {
            return weekdaySymbols[index]
        }
        return "Day \(dayOfWeek)"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
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
    
    private func startWorkout(_ workout: Workout) {
        // Navigate to workout detail view for this workout
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootViewController = windowScene?.windows.first?.rootViewController
        
        let hostingController = UIHostingController(
            rootView: WorkoutDetailView(workout: workout, isPresentedModally: true)
                .environmentObject(dataManager)
                .environmentObject(unitManager)
        )
        
        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.modalPresentationStyle = .fullScreen
        
        rootViewController?.present(navigationController, animated: true)
    }
    
    // Helper methods for Today's Workout section
    private func createEmptyWorkout() {
        guard let user = dataManager.getCurrentUser() else { return }
        
        let newWorkout = dataManager.createWorkout(for: user, date: Date(), name: "New Workout")
        startWorkout(newWorkout)
    }
    
    private func showQuickSelect() {
        // For now, this would just open the workouts list with a filter to only show completed workouts
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootViewController = windowScene?.windows.first?.rootViewController
        
        // Create a simple alert instead of a potentially problematic sheet
        guard let viewController = rootViewController else { return }
        
        let alertController = UIAlertController(
            title: "Choose Action",
            message: "What would you like to do?",
            preferredStyle: .actionSheet
        )
        
        // Add option to view all workouts
        alertController.addAction(UIAlertAction(
            title: "View All Workouts",
            style: .default,
            handler: { _ in
                // Present the workouts list view safely
                let hostingController = UIHostingController(
                    rootView: WorkoutsListView()
                        .environmentObject(dataManager)
                        .environmentObject(unitManager)
                )
                
                let navigationController = UINavigationController(rootViewController: hostingController)
                navigationController.modalPresentationStyle = .automatic
                
                viewController.present(navigationController, animated: true)
            }
        ))
        
        // Add option to repeat most recent workout
        if let mostRecentWorkout = recentWorkouts.first {
            alertController.addAction(UIAlertAction(
                title: "Repeat Latest: \(mostRecentWorkout.name ?? "Workout")",
                style: .default,
                handler: { _ in
                    self.startWorkout(mostRecentWorkout)
                }
            ))
        }
        
        // Cancel option
        alertController.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel
        ))
        
        // For iPad, set the source view for the popover
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = [] 
        }
        
        viewController.present(alertController, animated: true)
    }
    
    private func getSuggestedWorkout() -> Workout? {
        // This is a simple implementation. In a more advanced version, you could:
        // 1. Analyze which muscle groups haven't been worked recently
        // 2. Look at the user's schedule and preferences
        // 3. Suggest workout based on workout history and frequency
        
        // For now, just return the most recent completed workout if available
        return recentWorkouts.first
    }
    
    private func getMuscleGroups(for workout: Workout) -> String? {
        guard let sets = workout.sets as? Set<WorkoutSet>, !sets.isEmpty else { return nil }
        
        // Get unique muscle groups
        var muscleGroups = Set<String>()
        for set in sets {
            if let muscleGroup = set.exercise?.targetMuscleGroup, !muscleGroup.isEmpty {
                muscleGroups.insert(muscleGroup)
            }
        }
        
        if muscleGroups.isEmpty {
            return nil
        }
        
        return muscleGroups.joined(separator: ", ")
    }
    
    // Helper methods for achievements section
    private func calculateStreak() -> (current: Int, longest: Int) {
        var current = 0
        var longest = 0
        
        let calendar = Calendar.current
        let today = Date()
        
        // Get sorted workout dates
        let workoutDates = workouts.compactMap { $0.date }
            .sorted(by: >)
        
        guard !workoutDates.isEmpty else { return (0, 0) }
        
        // Check if worked out today
        if let latestWorkoutDate = workoutDates.first,
           calendar.isDate(latestWorkoutDate, inSameDayAs: today) {
            current = 1
        } else {
            // Check if yesterday's workout exists
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            if let latestWorkoutDate = workoutDates.first,
               calendar.isDate(latestWorkoutDate, inSameDayAs: yesterday) {
                current = 1
            } else {
                return (0, calculateLongestStreak(from: workoutDates))
            }
        }
        
        // Count consecutive days
        var checkDate = calendar.date(byAdding: .day, value: -1, to: today)!
        
        for i in 1..<workoutDates.count {
            if calendar.isDate(workoutDates[i], inSameDayAs: checkDate) {
                current += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        
        longest = calculateLongestStreak(from: workoutDates)
        
        return (current, longest)
    }
    
    private func calculateLongestStreak(from dates: [Date]) -> Int {
        var longest = 0
        var currentStreak = 1
        
        let calendar = Calendar.current
        var datesToProcess = dates.sorted()
        
        guard datesToProcess.count > 1 else { return datesToProcess.count }
        
        for i in 1..<datesToProcess.count {
            let previous = datesToProcess[i-1]
            let currentDate = datesToProcess[i]
            
            let daysBetween = calendar.dateComponents([.day], from: previous, to: currentDate).day ?? 0
            
            if daysBetween == 1 {
                currentStreak += 1
                longest = max(longest, currentStreak)
            } else if daysBetween != 0 {
                // Reset streak for gap larger than 1 day
                currentStreak = 1
            }
        }
        
        return max(longest, 1)
    }
    
    private struct PersonalRecord: Identifiable {
        let id = UUID()
        let exerciseName: String
        let weight: Double
        let reps: Int16
        let date: Date
    }
    
    private func getRecentPersonalRecords() -> [PersonalRecord]? {
        let calendar = Calendar.current
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!
        
        var prs: [PersonalRecord] = []
        var exerciseBestLifts: [NSManagedObjectID: (weight: Double, reps: Int16, date: Date)] = [:]
        
        // Find the best lift for each exercise from current workouts
        for workout in workouts {
            guard let date = workout.date, date >= oneMonthAgo else { continue }
            guard let sets = workout.sets as? Set<WorkoutSet> else { continue }
            
            for set in sets {
                guard let exercise = set.exercise else { continue }
                let exerciseID = exercise.objectID
                
                // For simplicity, we're just tracking max weight, but you could use a more sophisticated formula
                if let currentBest = exerciseBestLifts[exerciseID] {
                    if set.weight > currentBest.weight {
                        exerciseBestLifts[exerciseID] = (set.weight, set.reps, date)
                    }
                } else {
                    exerciseBestLifts[exerciseID] = (set.weight, set.reps, date)
                }
            }
        }
        
        // Find the best lift for each exercise from exercise history
        addHistoricalPersonalRecords(to: &exerciseBestLifts, since: oneMonthAgo)
        
        // Convert to PR records
        for (exerciseID, liftData) in exerciseBestLifts {
            guard let exercise = try? dataManager.context.existingObject(with: exerciseID) as? Exercise,
                  let name = exercise.name else { continue }
            
            prs.append(PersonalRecord(
                exerciseName: name,
                weight: liftData.weight,
                reps: liftData.reps,
                date: liftData.date
            ))
        }
        
        // Sort by date, most recent first
        prs.sort { $0.date > $1.date }
        
        return prs
    }
    
    // New method to add historical personal records
    private func addHistoricalPersonalRecords(to exerciseBestLifts: inout [NSManagedObjectID: (weight: Double, reps: Int16, date: Date)], since date: Date) {
        guard let user = dataManager.getCurrentUser() else { return }
        
        let fetchRequest: NSFetchRequest<ExerciseHistory> = ExerciseHistory.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "user == %@ AND date >= %@",
            user, date as NSDate
        )
        
        do {
            let historyRecords = try dataManager.context.fetch(fetchRequest)
            
            for record in historyRecords {
                guard let exercise = record.exercise, let recordDate = record.date else { continue }
                let exerciseID = exercise.objectID
                
                if let currentBest = exerciseBestLifts[exerciseID] {
                    if record.maxWeight > currentBest.weight {
                        exerciseBestLifts[exerciseID] = (record.maxWeight, record.repsAtMaxWeight, recordDate)
                    }
                } else {
                    exerciseBestLifts[exerciseID] = (record.maxWeight, record.repsAtMaxWeight, recordDate)
                }
            }
        } catch {
            print("Error fetching historical personal records: \(error)")
        }
    }
    
    private func formatWeight(_ weight: Double) -> String {
        let isMetric = unitManager.unitSystem == .metric
        let unit = isMetric ? "kg" : "lb"
        return String(format: "%.1f \(unit)", weight)
    }
    
    // New method to calculate workout streak
    private func calculateCurrentStreak() -> Int {
        guard !workouts.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var currentDate = today
        
        // Get all workout dates
        var workoutDays = Set<Date>()
        for workout in workouts {
            if let date = workout.date {
                workoutDays.insert(calendar.startOfDay(for: date))
            }
        }
        
        // Add historical workout days
        addHistoricalWorkoutDays(to: &workoutDays)
        
        // Calculate consecutive streak
        while workoutDays.contains(currentDate) || calendar.isDateInWeekend(currentDate) {
            if workoutDays.contains(currentDate) {
                streak += 1
            }
            
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            currentDate = previousDay
        }
        
        return streak
    }
    
    // New method to add historical workout days
    private func addHistoricalWorkoutDays(to workoutDays: inout Set<Date>) {
        guard let user = dataManager.getCurrentUser() else { return }
        let calendar = Calendar.current
        
        let fetchRequest: NSFetchRequest<ExerciseHistory> = ExerciseHistory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user == %@", user)
        
        do {
            let historyRecords = try dataManager.context.fetch(fetchRequest)
            
            for record in historyRecords {
                if let date = record.date {
                    workoutDays.insert(calendar.startOfDay(for: date))
                }
            }
        } catch {
            print("Error fetching historical workout days: \(error)")
        }
    }
}

// Component for section headers with icons
struct SectionHeader: View {
    var title: String
    var icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blue)
            
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}

// Empty state component
struct EmptyStateView: View {
    var message: String
    var icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundColor(.secondary.opacity(0.7))
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}

// Updated HomeWorkoutCard with modern design
struct HomeWorkoutCard: View {
    var workout: Workout
    var unitManager: UnitManager
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Workout icon with colored background
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.blue.opacity(0.7), .blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            // Workout details
            VStack(alignment: .leading, spacing: 6) {
                Text(workout.name ?? "Workout")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                if let sets = workout.sets as? Set<WorkoutSet>, !sets.isEmpty {
                    let exercisesList = getFormattedExercises(from: sets)
                    Text(exercisesList)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 12) {
                    if let date = workout.date {
                        Label(formatDate(date), systemImage: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    if workout.duration > 0 {
                        Label(formatDuration(workout.duration), systemImage: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Sets count with badge
            if let sets = workout.sets as? Set<WorkoutSet> {
                Text("\(sets.count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.green)
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white, lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) min"
        }
    }
    
    private func getFormattedExercises(from sets: Set<WorkoutSet>) -> String {
        // Get unique exercises in the order they appear in the set
        var exerciseNames = [String]()
        var seenExerciseIDs = Set<NSManagedObjectID>()
        
        // Process sets without sorting since WorkoutSet doesn't have an order property
        for set in sets {
            if let exercise = set.exercise, !seenExerciseIDs.contains(exercise.objectID) {
                seenExerciseIDs.insert(exercise.objectID)
                if let name = exercise.name {
                    exerciseNames.append(name)
                }
            }
        }
        
        if exerciseNames.isEmpty {
            return "No exercises"
        }
        
        // List exercises with bullet points instead of commas
        return exerciseNames.prefix(4).map { "• \($0)" }.joined(separator: "  ")
            + (exerciseNames.count > 4 ? "  •••" : "")
    }
}

struct WeeklyActivityItem: Identifiable {
    var id = UUID()
    var day: String
    var sets: Int
}

struct WorkoutStats {
    var totalWorkouts: Int = 0
    var workoutsThisWeek: Int = 0
    var totalDuration: Double = 0
    var totalSets: Int = 0
    var uniqueExercises: Int = 0
    var currentStreak: Int = 0
    var consistency: Double = 0.0
}

// Data structure for upcoming workouts
struct ScheduledWorkoutInfo: Identifiable {
    let id: UUID
    let dayOfWeek: Int16
    let dayName: String
    let date: Date
    let formattedDate: String?
    let timeOfDay: Date?
    let formattedTime: String?
    let workout: Workout?
    let notes: String?
} 
