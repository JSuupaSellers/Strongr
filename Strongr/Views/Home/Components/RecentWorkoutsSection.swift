import SwiftUI

struct RecentWorkoutsSection: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var unitManager: UnitManager
    var recentWorkouts: [Workout]
    
    var body: some View {
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
} 