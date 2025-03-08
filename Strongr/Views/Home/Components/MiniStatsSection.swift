import SwiftUI

struct MiniStatsSection: View {
    var workoutStats: WorkoutStats
    
    var body: some View {
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
} 
