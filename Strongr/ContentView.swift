//
//  ContentView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var unitManager: UnitManager
    @State private var activeSchedule: WorkoutSchedule?
    @State private var showingOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            TabView {
                NavigationView {
                    HomeView()
                        .environmentObject(unitManager)
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                
                NavigationView {
                    WorkoutsListView()
                        .environmentObject(unitManager)
                }
                .tabItem {
                    Label("Workouts", systemImage: "figure.strengthtraining.traditional")
                }
                
                NavigationView {
                    Group {
                        if let schedule = activeSchedule {
                            ScheduleView(schedule: schedule)
                        } else {
                            VStack(spacing: 20) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary)
                                    .padding()
                                
                                Text("No Active Schedule")
                                    .font(.headline)
                                
                                Text("Create a schedule to plan your workouts")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    showScheduleManager()
                                }) {
                                    Text("Create Schedule")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                                .padding(.top, 12)
                            }
                            .navigationTitle("Schedule")
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: {
                                        showScheduleManager()
                                    }) {
                                        Image(systemName: "gear")
                                    }
                                }
                            }
                        }
                    }
                    .environmentObject(unitManager)
                }
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
                
                NavigationView {
                    ExercisesView()
                        .environmentObject(unitManager)
                }
                .tabItem {
                    Label("Exercises", systemImage: "dumbbell")
                }
                
                NavigationView {
                    StatsView()
                        .environmentObject(unitManager)
                }
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.xaxis")
                }
            }
            .onAppear {
                loadActiveSchedule()
                checkForFirstLaunch()
            }
            
            // Show onboarding view as overlay when needed
            if showingOnboarding {
                OnboardingView()
                    .environmentObject(dataManager)
                    .environmentObject(unitManager)
                    .transition(.opacity)
                    .zIndex(1) // Ensure it's on top
            }
        }
        .animation(.easeInOut, value: showingOnboarding)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("OnboardingCompleted"))) { _ in
            showingOnboarding = false
        }
    }
    
    private func loadActiveSchedule() {
        let request = NSFetchRequest<WorkoutSchedule>(entityName: "WorkoutSchedule")
        request.predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true))
        request.fetchLimit = 1
        
        do {
            let results = try dataManager.context.fetch(request)
            activeSchedule = results.first
        } catch {
            print("Error fetching active schedule: \(error)")
        }
    }
    
    private func checkForFirstLaunch() {
        // Check if this is the first launch
        if dataManager.isFirstLaunch() {
            showingOnboarding = true
        }
    }
    
    private func showScheduleManager() {
        // Present the schedule manager as a sheet
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootViewController = windowScene?.windows.first?.rootViewController
        
        let hostingController = UIHostingController(
            rootView: ScheduleManagerView()
                .environmentObject(dataManager)
                .environmentObject(unitManager)
                .onDisappear {
                    // Reload active schedule when the manager is dismissed
                    loadActiveSchedule()
                }
        )
        
        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.modalPresentationStyle = .fullScreen
        
        rootViewController?.present(navigationController, animated: true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataManager.preview)
            .environmentObject(UnitManager())
    }
}