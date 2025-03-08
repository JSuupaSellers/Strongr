//
//  ProfileView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI
import CoreData

// MARK: - Profile View
struct ProfileView: View {
    // Environment objects needed for backward compatibility
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var unitManager: UnitManager
    
    // View model with dependency injection
    @StateObject private var viewModel: ProfileViewModel
    
    // State for UI only
    @State private var isEditing: Bool = false
    @State private var showingUnitSelector = false
    @State private var showOnboardingResetAlert = false
    
    init() {
        // Initialize view model with service dependencies
        let serviceLocator = ServiceLocator.shared
        _viewModel = StateObject(wrappedValue: ProfileViewModel(
            dataService: serviceLocator.dataService,
            statsService: serviceLocator.statsService,
            unitService: serviceLocator.unitService
        ))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background color
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header with avatar
                    ProfileHeaderCard(
                        userName: viewModel.user?.name ?? "Your Name"
                    )
                    
                    // User information section
                    VStack(spacing: 0) {
                        if isEditing {
                            EditProfileForm(
                                name: $viewModel.name,
                                age: $viewModel.age,
                                height: $viewModel.height,
                                weight: $viewModel.weight,
                                currentUnitSystem: viewModel.getCurrentUnitSystem()
                            )
                        } else {
                            ProfileInfoCard(
                                user: viewModel.user,
                                formatHeight: viewModel.formatHeight,
                                formatWeight: viewModel.formatWeight,
                                formattedBMI: viewModel.formattedBMI
                            )
                        }
                    }
                    
                    // Statistics summary
                    StatsCard(
                        workoutStats: viewModel.workoutStats
                    )
                    
                    // Achievements section
                    AchievementsCard()
                    
                    // Settings and preferences
                    SettingsCard(
                        onUnitsTap: { showingUnitSelector = true },
                        onResetOnboardingTap: { showOnboardingResetAlert = true },
                        unitSystemDisplayName: viewModel.getCurrentUnitSystem() == .metric ? "Metric" : "Imperial"
                    )
                    
                    // App information
                    AppInfoCard()
                    
                    // Bottom padding
                    Spacer().frame(height: 20)
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if isEditing {
                        viewModel.saveProfile()
                    }
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Save" : "Edit")
                        .fontWeight(.medium)
                }
            }
        }
        .onAppear {
            viewModel.loadData()
        }
        .sheet(isPresented: $showingUnitSelector) {
            UnitSystemSelector(
                currentUnitSystem: viewModel.getCurrentUnitSystem(),
                onMetricSelected: {
                    ServiceLocator.shared.unitService.setUnitSystem(.metric)
                    showingUnitSelector = false
                    viewModel.loadData()
                },
                onImperialSelected: {
                    ServiceLocator.shared.unitService.setUnitSystem(.imperial)
                    showingUnitSelector = false
                    viewModel.loadData()
                },
                onDismiss: {
                    showingUnitSelector = false
                }
            )
        }
        .alert("Reset Onboarding?", isPresented: $showOnboardingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                viewModel.resetOnboarding()
                
                // Show a message to the user
                let alertController = UIAlertController(
                    title: "Onboarding Reset",
                    message: "The onboarding flow has been reset. Please restart the app to see the onboarding screens. Don't worry - your existing exercises won't be duplicated.",
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                
                // Present the alert
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let viewController = windowScene.windows.first?.rootViewController {
                    viewController.present(alertController, animated: true)
                }
            }
        } message: {
            Text("This will reset the onboarding flow so you can test it again. You'll need to restart the app to see the changes.")
        }
    }
} 
