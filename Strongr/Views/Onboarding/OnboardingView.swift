import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var unitManager: UnitManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentPage = 0
    @State private var userName = ""
    @State private var userWeight = 150.0  // Default starting weight in pounds/kg
    @State private var userHeightFeet = 5  // Default feet
    @State private var userHeightInches = 10  // Default inches
    @State private var userHeightCm = 170.0  // Default cm
    @State private var birthDate = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()  // Default: 30 years ago
    @State private var selectedUnitSystem: UnitManager.UnitSystem = .imperial
    @State private var userGoal = "Get stronger"
    
    // Track whether pickers are expanded
    @State private var isWeightPickerExpanded = false
    @State private var isHeightPickerExpanded = false
    @State private var isDatePickerExpanded = false
    @State private var isGoalPickerExpanded = false
    
    // Available fitness goals
    let fitnessGoals = ["Get stronger", "Build muscle", "Lose weight", "Improve fitness", "Train for sport"]
    
    // Total number of pages
    let totalPages = 5
    
    // Main view body
    var body: some View {
        ZStack {
            // Background color
            Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            
            // Content based on current page
            VStack(spacing: 0) {
                // Progress bar instead of dots
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: UIScreen.main.bounds.width * CGFloat(currentPage) / CGFloat(totalPages - 1), height: 4)
                }
                .padding(.top)
                
                // Page content
                ZStack {
                    welcomeScreen
                        .opacity(currentPage == 0 ? 1 : 0)
                    
                    nameScreen
                        .opacity(currentPage == 1 ? 1 : 0)
                    
                    ageScreen
                        .opacity(currentPage == 2 ? 1 : 0)
                    
                    unitsScreen
                        .opacity(currentPage == 3 ? 1 : 0)
                    
                    bodyStatsScreen
                        .opacity(currentPage == 4 ? 1 : 0)
                }
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Navigation buttons
                HStack(spacing: 20) {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                                resetExpandedState()
                            }
                        }) {
                            Text("Back")
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                    
                    if currentPage < totalPages - 1 {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                                resetExpandedState()
                            }
                        }) {
                            HStack {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(canAdvance ? Color.blue : Color.gray)
                            .cornerRadius(10)
                        }
                        .disabled(!canAdvance)
                    } else {
                        Button(action: completeOnboarding) {
                            Text("Get Started")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
            .padding(.vertical)
        }
        .onAppear {
            // Load the user's preferences on appear
            if let system = UserDefaults.standard.string(forKey: "unitSystem"),
               let unitSystem = UnitManager.UnitSystem(rawValue: system) {
                selectedUnitSystem = unitSystem
            }
        }
    }
    
    // Determine if we can advance to the next screen based on current input
    private var canAdvance: Bool {
        switch currentPage {
        case 1: return !userName.isEmpty  // Name screen
        default: return true  // Other screens have default values
        }
    }
    
    // Welcome screen
    private var welcomeScreen: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Welcome to Strongr")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("Your personal workout tracker to help you reach your fitness goals")
                .font(.system(size: 18))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    // Name entry screen
    private var nameScreen: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("What's your name?")
                .font(.system(size: 28, weight: .bold))
            
            Text("We'll use this to personalize your experience")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            TextField("Enter your name", text: $userName)
                .font(.system(size: 20))
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .autocapitalization(.words)
                .disableAutocorrection(true)
            
            Spacer()
        }
        .padding(.top, 60)
        .padding(.horizontal, 24)
    }
    
    // Age entry screen
    private var ageScreen: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("When were you born?")
                .font(.system(size: 28, weight: .bold))
            
            Text("We'll use this to tailor recommendations")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            VStack {
                HStack {
                    Text(formattedBirthDate)
                        .font(.system(size: 20))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    Button(action: {
                        withAnimation {
                            isDatePickerExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isDatePickerExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
                
                if isDatePickerExpanded {
                    DatePicker(
                        "Birth Date",
                        selection: $birthDate,
                        in: ...Date(),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding(.vertical, 8)
                    .transition(.opacity)
                }
            }
            
            Spacer()
        }
        .padding(.top, 60)
        .padding(.horizontal, 24)
    }
    
    // Units selection screen
    private var unitsScreen: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("Which units do you prefer?")
                .font(.system(size: 28, weight: .bold))
            
            Text("You can change this anytime in settings")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                unitButton(title: "Imperial (lb, ft/in, mi)", system: .imperial)
                unitButton(title: "Metric (kg, cm, km)", system: .metric)
            }
            
            Spacer()
        }
        .padding(.top, 60)
        .padding(.horizontal, 24)
    }
    
    // Body stats screen
    private var bodyStatsScreen: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Your body stats")
                .font(.system(size: 28, weight: .bold))
            
            Text("This helps us calculate your progress")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            // Weight input
            VStack(alignment: .leading, spacing: 12) {
                Text("Weight")
                    .font(.headline)
                
                HStack {
                    Text("\(String(format: "%.1f", userWeight)) \(selectedUnitSystem == .imperial ? "lbs" : "kg")")
                        .font(.system(size: 20))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    Button(action: {
                        withAnimation {
                            isWeightPickerExpanded.toggle()
                            isHeightPickerExpanded = false
                            isGoalPickerExpanded = false
                        }
                    }) {
                        Image(systemName: isWeightPickerExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
                
                if isWeightPickerExpanded {
                    Slider(value: $userWeight,
                           in: selectedUnitSystem == .imperial ? 50...350 : 30...180,
                           step: selectedUnitSystem == .imperial ? 1 : 0.5)
                    .padding(.vertical, 8)
                    .transition(.opacity)
                }
            }
            .padding(.top, 8)
            
            // Height input
            VStack(alignment: .leading, spacing: 12) {
                Text("Height")
                    .font(.headline)
                
                HStack {
                    Text(heightDisplayString)
                        .font(.system(size: 20))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    Button(action: {
                        withAnimation {
                            isHeightPickerExpanded.toggle()
                            isWeightPickerExpanded = false
                            isGoalPickerExpanded = false
                        }
                    }) {
                        Image(systemName: isHeightPickerExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
                
                if isHeightPickerExpanded {
                    if selectedUnitSystem == .imperial {
                        HStack {
                            Picker("Feet", selection: $userHeightFeet) {
                                ForEach(1...7, id: \.self) { feet in
                                    Text("\(feet) ft").tag(feet)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(maxWidth: .infinity)
                            
                            Picker("Inches", selection: $userHeightInches) {
                                ForEach(0...11, id: \.self) { inches in
                                    Text("\(inches) in").tag(inches)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(maxWidth: .infinity)
                        }
                        .frame(height: 120)
                    } else {
                        Slider(value: $userHeightCm, in: 120...220, step: 0.5)
                            .padding(.vertical, 8)
                    }
                }
            }
            
            // Fitness Goal
            VStack(alignment: .leading, spacing: 12) {
                Text("Your primary fitness goal")
                    .font(.headline)
                
                HStack {
                    Text(userGoal)
                        .font(.system(size: 20))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    Button(action: {
                        withAnimation {
                            isGoalPickerExpanded.toggle()
                            isWeightPickerExpanded = false
                            isHeightPickerExpanded = false
                        }
                    }) {
                        Image(systemName: isGoalPickerExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
                
                if isGoalPickerExpanded {
                    Menu {
                        ForEach(fitnessGoals, id: \.self) { goal in
                            Button(goal) {
                                userGoal = goal
                                isGoalPickerExpanded = false
                            }
                        }
                    } label: {
                        Text("Select a goal")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                    .transition(.opacity)
                }
            }
        }
        .padding(.top, 40)
        .padding(.horizontal, 24)
    }
    
    // Helper UI components
    private func unitButton(title: String, system: UnitManager.UnitSystem) -> some View {
        Button(action: {
            selectedUnitSystem = system
        }) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                    .font(.system(size: 18))
                
                Spacer()
                
                if selectedUnitSystem == system {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedUnitSystem == system ? Color.blue.opacity(0.1) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedUnitSystem == system ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
    }
    
    // Reset all expanded states when changing pages
    private func resetExpandedState() {
        isWeightPickerExpanded = false
        isHeightPickerExpanded = false
        isDatePickerExpanded = false
        isGoalPickerExpanded = false
    }
    
    // Format birth date for display
    private var formattedBirthDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: birthDate)
    }
    
    // Format height for display
    private var heightDisplayString: String {
        if selectedUnitSystem == .imperial {
            return "\(userHeightFeet)′ \(userHeightInches)″"
        } else {
            return "\(String(format: "%.1f", userHeightCm)) cm"
        }
    }
    
    // Get height in inches from feet/inches input
    private func getHeightInInches() -> Double {
        return Double(userHeightFeet * 12 + userHeightInches)
    }
    
    // Calculate age from birth date
    private func calculateAge() -> Int16 {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return Int16(ageComponents.year ?? 0)
    }
    
    // Handle onboarding completion
    private func completeOnboarding() {
        // Process height based on unit system
        let heightValue: Double = selectedUnitSystem == .imperial ? getHeightInInches() : userHeightCm
        
        // Calculate age from birth date
        let ageValue = calculateAge()
        
        // Create or update user
        var user: User? = dataManager.getCurrentUser()
        
        if user == nil {
            // Create new user with required parameters
            // When creating a new user, make sure weight is converted to metric first
            let metricWeight: Double = selectedUnitSystem == .metric ? 
                userWeight : 
                unitManager.convertWeight(userWeight, from: .imperial, to: .metric)
            
            let metricHeight: Double = selectedUnitSystem == .metric ? 
                heightValue : 
                unitManager.convertHeight(heightValue, from: .imperial, to: .metric)
            
            user = dataManager.createUser(
                name: userName,
                weight: metricWeight,
                height: metricHeight,
                age: ageValue
            )
            
            print("Created new user with weight: \(userWeight) \(selectedUnitSystem.weightUnit) -> \(metricWeight) kg")
        } else {
            // Update existing user
            user?.name = userName
            
            // Always store in metric in the database
            let metricWeight = selectedUnitSystem == .metric ? 
                userWeight : 
                unitManager.convertWeight(userWeight, from: .imperial, to: .metric)
            user?.weight = metricWeight
            print("Updated user weight: \(userWeight) \(selectedUnitSystem.weightUnit) -> \(metricWeight) kg")
            
            // Always store in metric in the database
            let metricHeight = selectedUnitSystem == .metric ? 
                heightValue : 
                unitManager.convertHeight(heightValue, from: .imperial, to: .metric)
            user?.height = metricHeight
            
            user?.age = ageValue
            
            // Save the changes
            dataManager.saveContext()
        }
        
        // Save unit preference
        unitManager.unitSystem = selectedUnitSystem
        
        // Mark onboarding as complete
        dataManager.completeOnboarding()
        
        // Close the onboarding view if presented modally
        presentationMode.wrappedValue.dismiss()
        
        // Notify parent view (in case this is embedded)
        NotificationCenter.default.post(name: NSNotification.Name("OnboardingCompleted"), object: nil)
    }
}

// Use a placeholder preview to avoid initialization errors
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        Text("OnboardingView Preview")
            .previewLayout(.sizeThatFits)
    }
} 