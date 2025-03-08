import SwiftUI

struct StatsCard: View {
    let workoutStats: WorkoutStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card header
            Text("Your Stats")
                .font(.headline)
                .cardHeader(color: .green)
            
            // Stats content
            HStack(spacing: 0) {
                statItem(value: "\(workoutStats.totalWorkouts)", label: "Workouts")
                
                Divider().frame(height: 80)
                
                statItem(value: "\(workoutStats.totalSets)", label: "Total Sets")
                
                Divider().frame(height: 80)
                
                let hours = workoutStats.totalDuration / 3600
                statItem(value: "\(String(format: "%.1f", hours))h", label: "Training Time")
            }
        }
        .cardStyle()
    }
    
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
} 