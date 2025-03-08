import SwiftUI
import UIKit

struct TodayWorkoutSection: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var unitManager: UnitManager
    var recentWorkouts: [Workout]
    @ObservedObject var viewModel: HomeViewModel
    
    init(recentWorkouts: [Workout], viewModel: HomeViewModel) {
        self.recentWorkouts = recentWorkouts
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Today's Workout", icon: "flame.fill")
            
            VStack(spacing: 16) {
                // Quick start buttons
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.createEmptyWorkout()
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
                        viewModel.showQuickSelect()
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
                if let suggestedWorkout = viewModel.getSuggestedWorkout() {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Suggested for Today")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(suggestedWorkout.name ?? "Workout")
                                    .font(.headline)
                                
                                if let muscleGroups = viewModel.getMuscleGroups(for: suggestedWorkout) {
                                    Text(muscleGroups)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.startWorkout(suggestedWorkout)
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
} 