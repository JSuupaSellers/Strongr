import SwiftUI
import CoreData

struct AchievementsSection: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var unitManager: UnitManager
    var workoutStats: WorkoutStats
    @ObservedObject var viewModel: HomeViewModel
    
    init(workoutStats: WorkoutStats, viewModel: HomeViewModel) {
        self.workoutStats = workoutStats
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Your Achievements", icon: "trophy.fill")
            
            VStack(spacing: 16) {
                // Current streak
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
                            
                            Text("\(viewModel.streakInfo.current) days")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.orange)
                        }
                        
                        if viewModel.streakInfo.current > 0 {
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
                if !viewModel.personalRecords.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Personal Records")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.leading, 4)
                        
                        VStack(spacing: 10) {
                            ForEach(viewModel.personalRecords.prefix(2)) { pr in
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    
                                    Text("\(pr.exerciseName)")
                                        .font(.system(size: 15, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Text("\(viewModel.formatWeight(pr.weight)) × \(pr.reps) reps")
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
} 