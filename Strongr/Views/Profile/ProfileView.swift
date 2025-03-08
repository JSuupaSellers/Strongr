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
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var unitManager: UnitManager
    
    @State private var user: User?
    
    // Form fields
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var isEditing: Bool = false
    
    // Sheet states
    @State private var showingUnitSelector = false
    @State private var showOnboardingResetAlert = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background color
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header with avatar
                    profileHeaderCard
                    
                    // User information section
                    VStack(spacing: 0) {
                        if isEditing {
                            editProfileForm
                        } else {
                            profileInfoCard
                        }
                    }
                    
                    // Statistics summary
                    statsCard
                    
                    // Achievements section
                    achievementsCard
                    
                    // Settings and preferences
                    settingsCard
                    
                    // App information
                    appInfoCard
                    
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
                        saveProfile()
                    } else {
                        startEditing()
                    }
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Save" : "Edit")
                        .fontWeight(.medium)
                }
            }
        }
        .onAppear {
            loadUserData()
        }
        .sheet(isPresented: $showingUnitSelector) {
            unitSystemSelectSheet
        }
        .alert("Reset Onboarding?", isPresented: $showOnboardingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                // Reset the onboarding flag
                UserDefaults.standard.set(false, forKey: "hasLaunchedBefore")
                
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
    
    // MARK: - UI Components
    
    private var profileHeaderCard: some View {
        VStack(spacing: 16) {
            // Avatar image
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(25)
                    .foregroundColor(.white)
            }
            .padding(.top, 16)
            
            // User name
            Text(user?.name ?? "Your Name")
                .font(.system(size: 24, weight: .bold))
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var profileInfoCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card header
            HStack {
                Text("Personal Information")
                    .font(.headline)
                    .padding()
                
                Spacer()
            }
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12, corners: [.topLeft, .topRight])
            
            // Card content
            VStack(spacing: 0) {
                Divider()
                
                infoRow(title: "Name", value: user?.name ?? "Not set")
                
                Divider()
                
                if let age = user?.age, age > 0 {
                    infoRow(title: "Age", value: "\(age) years")
                    Divider()
                }
                
                if let height = user?.height, height > 0 {
                    infoRow(
                        title: "Height", 
                        value: unitManager.formatHeight(height)
                    )
                    Divider()
                }
                
                if let weight = user?.weight, weight > 0 {
                    infoRow(
                        title: "Weight", 
                        value: unitManager.formatWeight(weight)
                    )
                    Divider()
                }
                
                // BMI calculation if both height and weight are available
                if let height = user?.height, let weight = user?.weight, height > 0, weight > 0 {
                    let bmi = calculateBMI(weight: weight, height: height)
                    infoRow(title: "BMI", value: String(format: "%.1f", bmi))
                }
            }
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var editProfileForm: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card header
            HStack {
                Text("Edit Profile")
                    .font(.headline)
                    .padding()
                
                Spacer()
            }
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12, corners: [.topLeft, .topRight])
            
            // Form fields
            VStack(spacing: 16) {
                // Name field
                formField(title: "Name", value: $name)
                
                // Age field
                formField(title: "Age", value: $age, keyboardType: .numberPad)
                
                // Height field
                heightFormField()
                
                // Weight field
                weightFormField()
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card header
            HStack {
                Text("Your Stats")
                    .font(.headline)
                    .padding()
                
                Spacer()
            }
            .background(Color.green.opacity(0.1))
            .cornerRadius(12, corners: [.topLeft, .topRight])
            
            // Stats content
            HStack(spacing: 0) {
                statItem(value: "12", label: "Workouts")
                
                Divider().frame(height: 80)
                
                statItem(value: "32", label: "Total Sets")
                
                Divider().frame(height: 80)
                
                statItem(value: "8.5h", label: "Training Time")
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var achievementsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card header
            HStack {
                Text("Achievements")
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    // View all achievements action
                }) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.trailing)
            }
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12, corners: [.topLeft, .topRight])
            
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
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card header
            HStack {
                Text("Settings")
                    .font(.headline)
                    .padding()
                
                Spacer()
            }
            .background(Color.purple.opacity(0.1))
            .cornerRadius(12, corners: [.topLeft, .topRight])
            
            // Settings content
            VStack(spacing: 0) {
                // Units setting
                Button(action: {
                    showingUnitSelector = true
                }) {
                    HStack {
                        Image(systemName: "ruler")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.purple)
                        
                        Text("Units")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(unitManager.unitSystem.displayName)
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding()
                }
                
                Divider()
                
                // Dark Mode setting
                Button(action: {
                    // Toggle theme action
                }) {
                    HStack {
                        Image(systemName: "moon.fill")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.purple)
                        
                        Text("Dark Mode")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("System")
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding()
                }
                
                Divider()
                
                // Notifications setting
                Button(action: {
                    // Privacy action
                }) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.purple)
                        
                        Text("Notifications")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding()
                }
                
                Divider()
                
                // Reset Onboarding (for testing purposes)
                Button(action: {
                    resetOnboarding()
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.red)
                        
                        Text("Reset Onboarding (Testing)")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding()
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var appInfoCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card header
            HStack {
                Text("About")
                    .font(.headline)
                    .padding()
                
                Spacer()
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12, corners: [.topLeft, .topRight])
            
            // App info content
            VStack(spacing: 0) {
                infoRow(title: "Version", value: "1.0.0")
                
                Divider()
                
                Button(action: {
                    // Privacy policy action
                }) {
                    HStack {
                        Text("Privacy Policy")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                
                Divider()
                
                Button(action: {
                    // Terms of service action
                }) {
                    HStack {
                        Text("Terms of Service")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var unitSystemSelectSheet: some View {
        NavigationView {
            List {
                ForEach(UnitManager.UnitSystem.allCases, id: \.self) { system in
                    Button(action: {
                        unitManager.unitSystem = system
                        showingUnitSelector = false
                    }) {
                        HStack {
                            Text(system.displayName)
                            
                            Spacer()
                            
                            if unitManager.unitSystem == system {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Select Unit System")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showingUnitSelector = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
    
    private func formField(title: String, value: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextField(title, text: value)
                .keyboardType(keyboardType)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
    
    private func heightFormField() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Height")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                TextField("Height", text: $height)
                    .keyboardType(.decimalPad)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Text(unitManager.unitSystem.heightUnit)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            }
        }
    }
    
    private func weightFormField() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weight")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                TextField("Weight", text: $weight)
                    .keyboardType(.decimalPad)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Text(unitManager.unitSystem.weightUnit)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            }
        }
    }
    
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
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
    
    // MARK: - Helper Functions
    
    private func calculateBMI(weight: Double, height: Double) -> Double {
        // BMI = weight (kg) / (height (m))^2
        // Convert height from cm to m
        let heightInMeters = height / 100
        let bmi = weight / (heightInMeters * heightInMeters)
        return bmi
    }
    
    // MARK: - Data Functions
    
    private func loadUserData() {
        user = dataManager.getCurrentUser()
        
        // Initialize form fields
        name = user?.name ?? ""
        age = user?.age ?? 0 > 0 ? "\(user!.age)" : ""
        
        // Measurements are stored in metric in the database
        // For display in the form, convert to current unit system
        if let userHeight = user?.height, userHeight > 0 {
            let convertedHeight = unitManager.convertHeight(userHeight, from: .metric, to: unitManager.unitSystem)
            height = String(format: "%.1f", convertedHeight)
        } else {
            height = ""
        }
        
        if let userWeight = user?.weight, userWeight > 0 {
            // Correctly convert from metric (stored in DB) to the current unit system
            let convertedWeight = unitManager.convertWeight(userWeight, from: .metric, to: unitManager.unitSystem)
            weight = String(format: "%.1f", convertedWeight)
            print("Loading weight: \(userWeight) kg -> \(convertedWeight) \(unitManager.unitSystem.weightUnit)")
        } else {
            weight = ""
        }
    }
    
    private func startEditing() {
        // Fields already initialized from loadUserData
    }
    
    private func saveProfile() {
        guard var currentUser = user else {
            // Create a new user if one doesn't exist
            let newUser = dataManager.createUser(
                name: name,
                weight: convertToMetric(weight: Double(weight) ?? 0),
                height: convertToMetric(height: Double(height) ?? 0),
                age: Int16(age) ?? 0
            )
            user = newUser
            return
        }
        
        // Update existing user
        currentUser.name = name
        
        if let ageValue = Int16(age) {
            currentUser.age = ageValue
        }
        
        // Always store values in metric in the database
        if let heightValue = Double(height) {
            let metricHeight = convertToMetric(height: heightValue)
            currentUser.height = metricHeight
        }
        
        if let weightValue = Double(weight) {
            let metricWeight = convertToMetric(weight: weightValue)
            currentUser.weight = metricWeight
            print("Saving weight: \(weightValue) \(unitManager.unitSystem.weightUnit) -> \(metricWeight) kg")
        }
        
        dataManager.saveContext()
        
        // Reload user data
        loadUserData()
    }
    
    private func convertToMetric(weight value: Double) -> Double {
        if value <= 0 {
            return 0
        }
        
        if unitManager.unitSystem == .imperial {
            // Convert from imperial to metric for storage
            let metricValue = unitManager.convertWeight(value, from: .imperial, to: .metric)
            return metricValue
        }
        return value  // Already in metric
    }
    
    private func convertToMetric(height value: Double) -> Double {
        if value <= 0 {
            return 0
        }
        
        if unitManager.unitSystem == .imperial {
            // Convert from imperial to metric for storage
            return unitManager.convertHeight(value, from: .imperial, to: .metric)
        }
        return value  // Already in metric
    }
    
    private func resetOnboarding() {
        showOnboardingResetAlert = true
    }
} 
