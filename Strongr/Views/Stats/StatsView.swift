import SwiftUI
import CoreData
import Charts

struct StatsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var unitManager: UnitManager
    @State private var workouts: [Workout] = []
    @State private var selectedTimeRange: TimeRange = .month
    @State private var exerciseStats: [ExerciseStats] = []
    @State private var volumeByDay: [VolumeByDay] = []
    @State private var workoutsByMuscleGroup: [MuscleGroupStats] = []
    @State private var workoutCompletionRate: Double = 0.0
    @State private var consecutiveWorkoutDays: Int = 0
    @State private var currentStreak: Int = 0
    
    enum TimeRange: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        case allTime = "All Time"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Time range selector
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .onChange(of: selectedTimeRange) { _ in
                        loadData()
                    }
                    
                    if workouts.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 36))
                                .foregroundColor(.secondary.opacity(0.7))
                            
                            Text("No workout data available")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Text("Complete workouts to see your stats")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        // Overall stats
                        overallStatsSection
                        
                        // Workout consistency
                        workoutConsistencySection
                        
                        // Exercise distribution
                        exerciseDistributionSection
                        
                        // Personal records
                        personalRecordsSection
                        
                        // Workout volume (de-emphasized but available)
                        workoutVolumeSection
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
            .onAppear {
                loadData()
            }
        }
    }
    
    private var overallStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overall Stats")
                .font(.headline)
                .padding(.leading)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(
                    title: "Workouts",
                    value: "\(workouts.count)",
                    icon: "figure.strengthtraining.traditional"
                )
                
                StatCard(
                    title: "Current Streak",
                    value: "\(currentStreak) days",
                    icon: "flame.fill"
                )
                
                StatCard(
                    title: "Avg. Duration",
                    value: "\(getAverageWorkoutDuration()) min",
                    icon: "timer"
                )
                
                StatCard(
                    title: "Consistency",
                    value: "\(Int(workoutCompletionRate * 100))%",
                    icon: "chart.bar.fill"
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var workoutConsistencySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Consistency")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 20) {
                // Consistency metrics
                HStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("Current Streak")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(currentStreak)")
                                .font(.system(size: 24, weight: .bold))
                            
                            Text("days")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading) {
                        Text("Completion Rate")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(workoutCompletionRate * 100))%")
                            .font(.system(size: 24, weight: .bold))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                
                // Calendar heatmap would go here in a more advanced implementation
                Text("Consistent workouts lead to better results")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            .padding(.vertical)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal)
        }
    }
    
    private var workoutVolumeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Workout Volume")
                .font(.headline)
                .foregroundColor(.secondary) // De-emphasized
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Total Volume")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(formatVolume(getTotalVolume()))
                            .font(.system(size: 20, weight: .bold))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Total Duration")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(formatHours(getTotalDuration()))
                            .font(.system(size: 20, weight: .bold))
                    }
                }
                .padding(.horizontal)
                
                if !volumeByDay.isEmpty {
                    // Simple line chart of volume over time
                    VStack(alignment: .leading) {
                        Text("Volume Trend")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.bottom, 8)
                        
                        GeometryReader { geometry in
                            Path { path in
                                // Find min and max volume for scaling
                                let maxVolume = volumeByDay.map { $0.volume }.max() ?? 1
                                
                                // Start at the first point
                                let firstPoint = CGPoint(
                                    x: 0,
                                    y: geometry.size.height * (1 - CGFloat(volumeByDay[0].volume / maxVolume))
                                )
                                path.move(to: firstPoint)
                                
                                // Draw the line
                                for (index, point) in volumeByDay.enumerated() {
                                    if index == 0 { continue }
                                    
                                    let point = CGPoint(
                                        x: geometry.size.width * CGFloat(index) / CGFloat(volumeByDay.count - 1),
                                        y: geometry.size.height * (1 - CGFloat(point.volume / maxVolume))
                                    )
                                    path.addLine(to: point)
                                }
                            }
                            .stroke(Color.blue, lineWidth: 2)
                        }
                        .frame(height: 100)
                        .padding(.vertical, 8)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal)
        }
    }
    
    private var exerciseDistributionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Most Used Exercises")
                .font(.headline)
                .padding(.horizontal)
            
            if exerciseStats.isEmpty {
                Text("No exercise data available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                VStack(spacing: 12) {
                    ForEach(exerciseStats.prefix(5)) { stat in
                        HStack {
                            Text(stat.name)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("\(stat.count) sets")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        ProgressBar(value: Double(stat.count) / Double(exerciseStats.first?.count ?? 1))
                            .frame(height: 8)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
    
    private var personalRecordsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Records")
                .font(.headline)
                .padding(.horizontal)
            
            if exerciseStats.isEmpty {
                Text("No personal records available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                VStack(spacing: 0) {
                    ForEach(exerciseStats.prefix(5)) { stat in
                        NavigationLink(destination: ExerciseDetailView(exercise: stat.exercise)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(stat.name)
                                        .fontWeight(.medium)
                                    
                                    if let prWeight = stat.prWeight, let prReps = stat.prReps {
                                        Text("\(formatWeight(prWeight)) × \(prReps) reps")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }
            }
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
    
    private func loadData() {
        guard let user = dataManager.getCurrentUser() else { return }
        
        let startDate = getDateRange(for: selectedTimeRange)
        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        
        // Set up predicate for the date range
        if let startDate = startDate {
            fetchRequest.predicate = NSPredicate(
                format: "user == %@ AND date >= %@",
                user, startDate as NSDate
            )
        } else {
            fetchRequest.predicate = NSPredicate(format: "user == %@", user)
        }
        
        // Sort by date descending
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            workouts = try dataManager.context.fetch(fetchRequest)
            calculateExerciseStats()
            
            // Calculate volume over time
            calculateVolumeByDay()
            
            // Calculate muscle group distribution
            calculateMuscleGroupDistribution()
            
            // Calculate new metrics
            calculateWorkoutConsistency()
            calculateCurrentStreak()
        } catch {
            print("Error fetching workouts: \(error)")
        }
    }
    
    private func getDateRange(for timeRange: TimeRange) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        
        switch timeRange {
        case .week:
            return calendar.date(byAdding: .day, value: -7, to: now)
        case .month:
            return calendar.date(byAdding: .month, value: -1, to: now)
        case .year:
            return calendar.date(byAdding: .year, value: -1, to: now)
        case .allTime:
            return nil
        }
    }
    
    private func calculateExerciseStats() {
        var exerciseCounts: [NSManagedObjectID: (exercise: Exercise, name: String, count: Int, prWeight: Double?, prReps: Int16?)] = [:]
        
        // First, get data from current workouts
        for workout in workouts {
            guard let sets = workout.sets as? Set<WorkoutSet> else { continue }
            
            for set in sets {
                guard let exercise = set.exercise else { continue }
                let exerciseID = exercise.objectID
                
                if var exerciseData = exerciseCounts[exerciseID] {
                    exerciseData.count += 1
                    
                    // Update PR if applicable
                    if let prWeight = exerciseData.prWeight, let prReps = exerciseData.prReps {
                        if set.weight > prWeight {
                            exerciseData.prWeight = set.weight
                            exerciseData.prReps = set.reps
                        } else if set.weight == prWeight && set.reps > prReps {
                            exerciseData.prReps = set.reps
                        }
                    } else {
                        exerciseData.prWeight = set.weight
                        exerciseData.prReps = set.reps
                    }
                    
                    exerciseCounts[exerciseID] = exerciseData
                } else {
                    exerciseCounts[exerciseID] = (
                        exercise: exercise,
                        name: exercise.name ?? "Unknown Exercise",
                        count: 1,
                        prWeight: set.weight,
                        prReps: set.reps
                    )
                }
            }
        }
        
        // Then, incorporate historical data
        fetchAndIncorporateExerciseHistory(into: &exerciseCounts)
        
        // Convert to array and sort by count
        exerciseStats = exerciseCounts.values.map { data in
            ExerciseStats(
                id: data.exercise.objectID.uriRepresentation().absoluteString,
                exercise: data.exercise,
                name: data.name,
                count: data.count,
                prWeight: data.prWeight,
                prReps: data.prReps
            )
        }
        .sorted { $0.count > $1.count }
    }
    
    // New method to incorporate exercise history into stats
    private func fetchAndIncorporateExerciseHistory(into exerciseCounts: inout [NSManagedObjectID: (exercise: Exercise, name: String, count: Int, prWeight: Double?, prReps: Int16?)]) {
        guard let user = dataManager.getCurrentUser() else { return }
        
        let fetchRequest: NSFetchRequest<ExerciseHistory> = ExerciseHistory.fetchRequest()
        
        // Get history records for the current user and selected time range
        if let startDate = getDateRange(for: selectedTimeRange) {
            fetchRequest.predicate = NSPredicate(
                format: "user == %@ AND date >= %@",
                user, startDate as NSDate
            )
        } else {
            fetchRequest.predicate = NSPredicate(format: "user == %@", user)
        }
        
        do {
            let historyRecords = try dataManager.context.fetch(fetchRequest)
            
            // Group history records by exercise and workout ID to avoid double-counting
            var recordsByExerciseAndWorkout: [NSManagedObjectID: [String: ExerciseHistory]] = [:]
            
            // First, organize records by exercise and workout ID
            for record in historyRecords {
                guard let exercise = record.exercise else { continue }
                let exerciseID = exercise.objectID
                
                if recordsByExerciseAndWorkout[exerciseID] == nil {
                    recordsByExerciseAndWorkout[exerciseID] = [:]
                }
                
                // Use workout ID if available, otherwise use date string as fallback
                let workoutIdentifier = record.workoutID ?? record.date?.description ?? UUID().uuidString
                recordsByExerciseAndWorkout[exerciseID]?[workoutIdentifier] = record
            }
            
            // Now process the organized records
            for (exerciseID, workoutRecords) in recordsByExerciseAndWorkout {
                // Get the best stats across all workout records for this exercise
                var bestWeight = 0.0
                var repsAtBestWeight: Int16 = 0
                var totalSets = 0
                
                for (_, record) in workoutRecords {
                    totalSets += Int(record.totalSets)
                    if record.maxWeight > bestWeight {
                        bestWeight = record.maxWeight
                        repsAtBestWeight = record.repsAtMaxWeight
                    }
                }
                
                if var exerciseData = exerciseCounts[exerciseID] {
                    // Add stats from history
                    exerciseData.count += totalSets
                    
                    // Update PR if the history has a better one
                    if let prWeight = exerciseData.prWeight, let prReps = exerciseData.prReps {
                        if bestWeight > prWeight {
                            exerciseData.prWeight = bestWeight
                            exerciseData.prReps = repsAtBestWeight
                        }
                    } else {
                        exerciseData.prWeight = bestWeight
                        exerciseData.prReps = repsAtBestWeight
                    }
                    
                    exerciseCounts[exerciseID] = exerciseData
                } else if let exercise = workoutRecords.values.first?.exercise {
                    // Create new entry from history
                    exerciseCounts[exerciseID] = (
                        exercise: exercise,
                        name: exercise.name ?? "Unknown Exercise",
                        count: totalSets,
                        prWeight: bestWeight,
                        prReps: repsAtBestWeight
                    )
                }
            }
        } catch {
            print("Error fetching exercise history: \(error)")
        }
    }
    
    private func calculateVolumeByDay() {
        let calendar = Calendar.current
        var volumeByDate: [Date: Double] = [:]
        
        // First calculate volume from current workouts
        for workout in workouts {
            guard let workoutDate = workout.date, let sets = workout.sets as? Set<WorkoutSet> else { continue }
            
            // Get date without time component
            let dateKey = calendar.startOfDay(for: workoutDate)
            
            // Calculate volume for this workout
            let workoutVolume = sets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
            
            volumeByDate[dateKey, default: 0] += workoutVolume
        }
        
        // Then incorporate historical volume data
        addHistoricalVolumeData(to: &volumeByDate)
        
        // Convert to array format for chart
        volumeByDay = volumeByDate.map { VolumeByDay(date: $0.key, volume: $0.value) }
            .sorted { $0.date < $1.date }
    }
    
    // New method to add historical volume data
    private func addHistoricalVolumeData(to volumeByDate: inout [Date: Double]) {
        guard let user = dataManager.getCurrentUser() else { return }
        let calendar = Calendar.current
        
        let fetchRequest: NSFetchRequest<ExerciseHistory> = ExerciseHistory.fetchRequest()
        
        if let startDate = getDateRange(for: selectedTimeRange) {
            fetchRequest.predicate = NSPredicate(
                format: "user == %@ AND date >= %@",
                user, startDate as NSDate
            )
        } else {
            fetchRequest.predicate = NSPredicate(format: "user == %@", user)
        }
        
        do {
            let historyRecords = try dataManager.context.fetch(fetchRequest)
            
            for record in historyRecords {
                guard let recordDate = record.date else { continue }
                
                // Get date without time component
                let dateKey = calendar.startOfDay(for: recordDate)
                
                // Add the volume from this historical record
                volumeByDate[dateKey, default: 0] += record.totalVolume
            }
        } catch {
            print("Error fetching exercise history for volume: \(error)")
        }
    }
    
    private func calculateMuscleGroupDistribution() {
        var muscleGroupCounts: [String: Int] = [:]
        
        for workout in workouts {
            guard let sets = workout.sets as? Set<WorkoutSet> else { continue }
            
            for set in sets {
                if let muscleGroup = set.exercise?.targetMuscleGroup, !muscleGroup.isEmpty {
                    muscleGroupCounts[muscleGroup, default: 0] += 1
                }
            }
        }
        
        // Convert to array for chart
        workoutsByMuscleGroup = muscleGroupCounts.map { MuscleGroupStats(name: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    private func getTotalVolume() -> Double {
        // Calculate volume from current workouts
        let currentVolume = workouts.reduce(0.0) { total, workout in
            let workoutSets = workout.sets as? Set<WorkoutSet> ?? []
            let workoutVolume = workoutSets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
            return total + workoutVolume
        }
        
        // Add historical volume from workouts not already counted
        return currentVolume + getHistoricalTotalVolume()
    }
    
    private func getHistoricalTotalVolume() -> Double {
        guard let user = dataManager.getCurrentUser() else { return 0 }
        
        let fetchRequest: NSFetchRequest<ExerciseHistory> = ExerciseHistory.fetchRequest()
        
        if let startDate = getDateRange(for: selectedTimeRange) {
            fetchRequest.predicate = NSPredicate(
                format: "user == %@ AND date >= %@",
                user, startDate as NSDate
            )
        } else {
            fetchRequest.predicate = NSPredicate(format: "user == %@", user)
        }
        
        do {
            let historyRecords = try dataManager.context.fetch(fetchRequest)
            
            // Get IDs of workouts already counted
            var existingWorkoutIDs = Set<String>()
            for workout in workouts {
                if let workoutID = workout.id?.uuidString {
                    existingWorkoutIDs.insert(workoutID)
                }
            }
            
            // Only sum up volume from history records that aren't already in workouts
            var additionalVolume = 0.0
            for record in historyRecords {
                if let workoutID = record.workoutID, !existingWorkoutIDs.contains(workoutID) {
                    additionalVolume += record.totalVolume
                }
            }
            
            return additionalVolume
        } catch {
            print("Error fetching historical volume: \(error)")
            return 0
        }
    }
    
    private func getTotalDuration() -> Double {
        workouts.reduce(0.0) { $0 + $1.duration }
    }
    
    private func getAverageWorkoutDuration() -> Int {
        guard !workouts.isEmpty else { return 0 }
        let totalSeconds = workouts.reduce(0.0) { $0 + $1.duration }
        let avgSeconds = totalSeconds / Double(workouts.count)
        return Int(avgSeconds / 60)  // Convert to minutes
    }
    
    private func formatVolume(_ volume: Double) -> String {
        let isMetric = unitManager.unitSystem == .metric
        let unit = isMetric ? "kg" : "lb"
        
        if volume > 1000 {
            return String(format: "%.1f k\(unit)", volume / 1000)
        } else {
            return String(format: "%.0f \(unit)", volume)
        }
    }
    
    private func formatWeight(_ weight: Double) -> String {
        let isMetric = unitManager.unitSystem == .metric
        let unit = isMetric ? "kg" : "lb"
        return String(format: "%.1f \(unit)", weight)
    }
    
    private func formatHours(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) min"
        }
    }
    
    private func calculateWorkoutConsistency() {
        guard let startDate = getDateRange(for: selectedTimeRange) else {
            workoutCompletionRate = workouts.isEmpty ? 0.0 : 1.0
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: startDate, to: now)
        
        guard let totalDays = components.day, totalDays > 0 else {
            workoutCompletionRate = 0.0
            return
        }
        
        // Count the total number of workouts instead of unique days
        let totalWorkouts = workouts.count
        
        // Add workouts from exercise history that aren't already in the workouts array
        let additionalWorkouts = getAdditionalWorkoutsFromHistory(since: startDate)
        
        workoutCompletionRate = Double(totalWorkouts + additionalWorkouts) / Double(totalDays)
    }
    
    // New method to count workouts from history that aren't already counted
    private func getAdditionalWorkoutsFromHistory(since startDate: Date) -> Int {
        guard let user = dataManager.getCurrentUser() else { return 0 }
        
        let fetchRequest: NSFetchRequest<ExerciseHistory> = ExerciseHistory.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "user == %@ AND date >= %@",
            user, startDate as NSDate
        )
        
        do {
            let historyRecords = try dataManager.context.fetch(fetchRequest)
            
            // Count workouts by their unique workoutID
            // This avoids double-counting workouts that are already in the workouts array
            var uniqueWorkoutIDs = Set<String>()
            
            for record in historyRecords {
                if let workoutID = record.workoutID {
                    uniqueWorkoutIDs.insert(workoutID)
                }
            }
            
            // Count existing workout IDs to avoid double counting
            var existingWorkoutIDs = Set<String>()
            for workout in workouts {
                if let workoutID = workout.id?.uuidString {
                    existingWorkoutIDs.insert(workoutID)
                }
            }
            
            // Only count workouts that aren't already in the workouts array
            let additionalWorkouts = uniqueWorkoutIDs.subtracting(existingWorkoutIDs).count
            return additionalWorkouts
            
        } catch {
            print("Error fetching historical workout records: \(error)")
            return 0
        }
    }
    
    // Modified to also use exercise history data
    private func calculateCurrentStreak() {
        guard !workouts.isEmpty else {
            // Check if there's any history before concluding streak is zero
            currentStreak = getHistoricalStreak()
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var currentDate = today
        
        // Using a different approach to avoid type inference issues
        // Create a set to store all workout days from both current workouts and history
        var workoutDays = Set<Date>()
        
        // Add current workout days
        for workout in workouts {
            if let date = workout.date {
                workoutDays.insert(calendar.startOfDay(for: date))
            }
        }
        
        // Add historical workout days
        addAllHistoricalWorkoutDays(to: &workoutDays)
        
        // Calculate consecutive streak
        while workoutDays.contains(currentDate) || calendar.isDateInWeekend(currentDate) {
            if workoutDays.contains(currentDate) {
                streak += 1
            }
            
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            currentDate = previousDay
            
            // Break if we've gone beyond the selected time range
            if let startDate = getDateRange(for: selectedTimeRange), currentDate < startDate {
                break
            }
        }
        
        currentStreak = streak
    }
    
    // New method to add all historical workout days
    private func addAllHistoricalWorkoutDays(to workoutDays: inout Set<Date>) {
        guard let user = dataManager.getCurrentUser() else { return }
        let calendar = Calendar.current
        
        let fetchRequest: NSFetchRequest<ExerciseHistory> = ExerciseHistory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user == %@", user)
        
        // No date filtering for streak calculation
        do {
            let historyRecords = try dataManager.context.fetch(fetchRequest)
            
            for record in historyRecords {
                if let date = record.date {
                    workoutDays.insert(calendar.startOfDay(for: date))
                }
            }
        } catch {
            print("Error fetching all historical workout days: \(error)")
        }
    }
    
    // New method to get streak just from history (when no current workouts)
    private func getHistoricalStreak() -> Int {
        guard let user = dataManager.getCurrentUser() else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var currentDate = today
        
        // Create a set to store all workout days from history
        var workoutDays = Set<Date>()
        
        // Fetch all historical workout days
        let fetchRequest: NSFetchRequest<ExerciseHistory> = ExerciseHistory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user == %@", user)
        
        do {
            let historyRecords = try dataManager.context.fetch(fetchRequest)
            
            for record in historyRecords {
                if let date = record.date {
                    workoutDays.insert(calendar.startOfDay(for: date))
                }
            }
            
            // Calculate consecutive streak
            while workoutDays.contains(currentDate) || calendar.isDateInWeekend(currentDate) {
                if workoutDays.contains(currentDate) {
                    streak += 1
                }
                
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousDay
                
                // Break if we've gone beyond the selected time range
                if let startDate = getDateRange(for: selectedTimeRange), currentDate < startDate {
                    break
                }
            }
            
            return streak
        } catch {
            print("Error calculating historical streak: \(error)")
            return 0
        }
    }
}

// MARK: - Supporting Views and Models
struct ProgressBar: View {
    var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .cornerRadius(5)
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: min(CGFloat(value) * geometry.size.width, geometry.size.width))
                    .cornerRadius(5)
            }
        }
    }
}

// Data models for stats
struct ExerciseStats: Identifiable {
    let id: String
    let exercise: Exercise
    let name: String
    let count: Int
    let prWeight: Double?
    let prReps: Int16?
}

struct VolumeByDay: Identifiable {
    let id = UUID()
    let date: Date
    let volume: Double
}

struct MuscleGroupStats: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
} 