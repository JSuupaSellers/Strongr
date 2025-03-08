import SwiftUI
import CoreData

// Card for displaying workout in the home view
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