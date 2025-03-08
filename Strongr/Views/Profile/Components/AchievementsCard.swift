import SwiftUI

struct AchievementsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card header
            HStack {
                Text("Achievements")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    // View all achievements action
                }) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .cardHeader(color: .orange)
            
            // Achievements content
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    achievementBadge(title: "First Workout", icon: "figure.walk", isCompleted: true)
                    achievementBadge(title: "10 Workouts", icon: "figure.strengthtraining.traditional", isCompleted: false)
                    achievementBadge(title: "5 Different Exercises", icon: "dumbbell", isCompleted: false)
                }
                .padding()
            }
        }
        .cardStyle()
    }
    
    private func achievementBadge(title: String, icon: String, isCompleted: Bool) -> some View {
        VStack {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.orange.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(isCompleted ? .orange : .gray)
            }
            
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(isCompleted ? .primary : .gray)
                .padding(.top, 4)
                .frame(maxWidth: .infinity)
        }
    }
} 