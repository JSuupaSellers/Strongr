import SwiftUI
import UIKit

/// Service class to handle common workout-related operations
class WorkoutService {
    static let shared = WorkoutService()
    
    private init() {}
    
    /// Starts a workout by presenting its detail view modally
    func startWorkout(_ workout: Workout, dataManager: DataManager, unitManager: UnitManager) {
        // Navigate to workout detail view for this workout
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootViewController = windowScene?.windows.first?.rootViewController
        
        let hostingController = UIHostingController(
            rootView: WorkoutDetailView(workout: workout, isPresentedModally: true)
                .environmentObject(dataManager)
                .environmentObject(unitManager)
        )
        
        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.modalPresentationStyle = .fullScreen
        
        rootViewController?.present(navigationController, animated: true)
    }
    
    /// Creates an empty workout and starts it
    func createAndStartEmptyWorkout(for user: User, dataManager: DataManager, unitManager: UnitManager) {
        let newWorkout = dataManager.createWorkout(for: user, date: Date(), name: "New Workout")
        startWorkout(newWorkout, dataManager: dataManager, unitManager: unitManager)
    }
    
    /// Shows a quick select action sheet for choosing workouts to repeat
    func showQuickSelectWorkoutDialog(recentWorkouts: [Workout], dataManager: DataManager, unitManager: UnitManager) {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootViewController = windowScene?.windows.first?.rootViewController
        
        guard let viewController = rootViewController else { return }
        
        let alertController = UIAlertController(
            title: "Choose Action",
            message: "What would you like to do?",
            preferredStyle: .actionSheet
        )
        
        // Add option to view all workouts
        alertController.addAction(UIAlertAction(
            title: "View All Workouts",
            style: .default,
            handler: { _ in
                // Present the workouts list view safely
                let hostingController = UIHostingController(
                    rootView: WorkoutsListView()
                        .environmentObject(dataManager)
                        .environmentObject(unitManager)
                )
                
                let navigationController = UINavigationController(rootViewController: hostingController)
                navigationController.modalPresentationStyle = .automatic
                
                viewController.present(navigationController, animated: true)
            }
        ))
        
        // Add option to repeat most recent workout
        if let mostRecentWorkout = recentWorkouts.first {
            alertController.addAction(UIAlertAction(
                title: "Repeat Latest: \(mostRecentWorkout.name ?? "Workout")",
                style: .default,
                handler: { _ in
                    self.startWorkout(mostRecentWorkout, dataManager: dataManager, unitManager: unitManager)
                }
            ))
        }
        
        // Cancel option
        alertController.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel
        ))
        
        // For iPad, set the source view for the popover
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = [] 
        }
        
        viewController.present(alertController, animated: true)
    }
    
    /// Gets muscle groups for a workout as a formatted string
    func getMuscleGroups(for workout: Workout) -> String? {
        guard let sets = workout.sets as? Set<WorkoutSet>, !sets.isEmpty else { return nil }
        
        // Get unique muscle groups
        var muscleGroups = Set<String>()
        for set in sets {
            if let muscleGroup = set.exercise?.targetMuscleGroup, !muscleGroup.isEmpty {
                muscleGroups.insert(muscleGroup)
            }
        }
        
        if muscleGroups.isEmpty {
            return nil
        }
        
        return muscleGroups.joined(separator: ", ")
    }
} 