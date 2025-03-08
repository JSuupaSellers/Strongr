//
//  HomeView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var unitManager: UnitManager
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Welcome message
                WelcomeSection(user: dataManager.getCurrentUser())
                
                // Today's Workout / Quick Start section
                TodayWorkoutSection(recentWorkouts: viewModel.recentWorkouts, viewModel: viewModel)
                    .environmentObject(dataManager)
                    .environmentObject(unitManager)
                
                // Upcoming scheduled workouts
                UpcomingWorkoutsSection(upcomingWorkouts: viewModel.upcomingWorkouts)
                    .environmentObject(dataManager)
                    .environmentObject(unitManager)
                
                // Recent workouts
                RecentWorkoutsSection(recentWorkouts: viewModel.recentWorkouts)
                    .environmentObject(dataManager)
                    .environmentObject(unitManager)
                
                // Recent achievements
                AchievementsSection(workoutStats: viewModel.workoutStats, viewModel: viewModel)
                    .environmentObject(dataManager)
                    .environmentObject(unitManager)
                
                // Mini stats with link to full stats
                MiniStatsSection(workoutStats: viewModel.workoutStats)
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
            // Give the view model access to the environment objects
            viewModel.setupWith(dataManager: dataManager, unitManager: unitManager)
            // Load the data
            viewModel.loadData()
        }
    }
}

