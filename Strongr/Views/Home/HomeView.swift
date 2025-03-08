//
//  HomeView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI

struct HomeView: View {
    // Environment objects needed for UI components
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var unitManager: UnitManager
    
    // ViewModel with dependency injection
    @StateObject private var viewModel: HomeViewModel
    
    init() {
        // Initialize view model with service dependencies
        let serviceLocator = ServiceLocator.shared
        _viewModel = StateObject(wrappedValue: HomeViewModel(
            dataService: serviceLocator.dataService,
            statsService: serviceLocator.statsService,
            workoutService: serviceLocator.workoutService,
            unitService: serviceLocator.unitService
        ))
    }
    
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
            // Load data (no need to pass managers now)
            viewModel.loadData()
        }
    }
}

