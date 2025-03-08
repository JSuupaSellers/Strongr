//
//  WorkoutSessionView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI
import CoreData
import Combine

struct WorkoutSessionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var unitManager: UnitManager
    
    let workout: Workout
    var isPresentedModally: Bool = false
    
    // Add workoutSession property
    @State private var workoutSession: WorkoutSession?
    
    // Session state
    @State private var isTimerRunning = false
    @State private var startTime = Date()
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
    // Tracking progress
    @State private var currentExerciseIndex = 0
    @State private var workoutSets: [WorkoutSet] = []
    @State private var groupedSets: [[WorkoutSet]] = []
    @State private var currentSetIndex = 0
    
    // Set editing
    @State private var editedWeight: Double = 0
    @State private var editedReps: Int16 = 0
    @State private var editedTime: Double = 0
    @State private var showingSetEditor = false
    
    // UI state
    @State private var showingConfirmation = false
    @State private var showingExerciseCompletion = false
    @State private var showingRestTimer = false
    @State private var restTimeRemaining: Int = 60
    @State private var restTimer: Timer?
    @State private var showCompletionAnimation = false
    @State private var showingWorkoutCompletion = false
    
    var body: some View {
        ZStack {
            // Show either the workout overview or the full-screen set view
            if workoutSets.isEmpty {
                loadingView
            } else if showingWorkoutCompletion {
                // Workout complete view
                workoutCompleteView
            } else if !showingRestTimer && !showingExerciseCompletion {
                if currentExerciseIndex < groupedSets.count && currentSetIndex < groupedSets[currentExerciseIndex].count {
                    // Full screen set view
                    let currentSets = groupedSets[currentExerciseIndex]
                    FullScreenSetView(
                        workoutSet: currentSets[currentSetIndex],
                        setIndex: currentSetIndex,
                        totalSets: currentSets.count,
                        onCompleteTapped: { reps, weight, time in
                            completeCurrentSet(reps: reps, weight: weight, time: time)
                        }
                    )
                } else {
                    // Should not reach here with the new logic
                    workoutCompleteView
                }
            }
            
            // Exercise completion sheet
            if showingExerciseCompletion {
                exerciseCompletionView
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
            }
            
            // Rest timer overlay
            if showingRestTimer {
                restTimerOverlay
                    .transition(.opacity)
                    .zIndex(3)
            }
            
            // Header and exit button remain visible
            VStack {
                HStack {
                    Button(action: {
                        showingConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "xmark")
                            Text("Exit")
                        }
                        .font(.headline)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Elapsed time
                    Text(formatTime(elapsedTime))
                        .font(.system(.headline, design: .monospaced))
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding()
                }
                
                Spacer()
            }
            .zIndex(4)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            startWorkoutSession()
        }
        .alert(isPresented: $showingConfirmation) {
            Alert(
                title: Text("Exit Workout?"),
                message: Text("Your progress will be saved, but the workout will be marked as incomplete."),
                primaryButton: .destructive(Text("Exit")) {
                    endWorkoutSession(completed: false)
                    if isPresentedModally {
                        // Dismiss the entire navigation stack by accessing the root controller
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootViewController = windowScene.windows.first?.rootViewController {
                            rootViewController.dismiss(animated: true)
                        }
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showingSetEditor) {
            editSetView
        }
        .edgesIgnoringSafeArea(.bottom)
        .hiddenTabBar()
    }
    
    // MARK: - UI Components
    
    var workoutHeader: some View {
        VStack(spacing: 8) {
            Text(workout.name ?? "Workout")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                Label(formatTime(elapsedTime), systemImage: "timer")
                    .foregroundColor(.white)
                
                Spacer()
                
                Label("\(completedSetsCount)/\(workoutSets.count)", systemImage: "repeat")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Loading workout...")
            Spacer()
        }
    }
    
    var workoutCompleteView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Celebration animation
            ZStack {
                ForEach(0..<5) { i in
                    Image(systemName: "star.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.yellow)
                        .offset(x: CGFloat.random(in: -150...150), y: CGFloat.random(in: -150...150))
                        .opacity(showCompletionAnimation ? 1 : 0)
                        .scaleEffect(showCompletionAnimation ? 1 : 0.1)
                        .animation(
                            Animation.spring(response: 0.4, dampingFraction: 0.5)
                                .delay(Double.random(in: 0...0.3))
                                .repeatCount(3, autoreverses: true),
                            value: showCompletionAnimation
                        )
                }
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 90))
                    .foregroundColor(.yellow)
                    .shadow(color: .orange.opacity(0.8), radius: 10, x: 0, y: 0)
                    .padding()
                    .scaleEffect(showCompletionAnimation ? 1.1 : 0.8)
                    .animation(
                        Animation.spring(response: 0.4, dampingFraction: 0.6)
                            .repeatCount(5, autoreverses: true),
                        value: showCompletionAnimation
                    )
            }
            .padding(.bottom, 20)
            
            Text("WORKOUT COMPLETE!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Congratulations! You've finished all your exercises.")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Workout stats summary in a card
            VStack(spacing: 25) {
                HStack(spacing: 40) {
                    VStack {
                        Text("\(completedSetsCount)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                        Text("SETS COMPLETED")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text(formatTime(elapsedTime))
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                        Text("TOTAL TIME")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // Calculate total volume
                let totalVolume = workoutSets.reduce(0) { result, set in
                    return set.completed ? result + (set.weight * Double(set.reps)) : result
                }
                
                VStack {
                    Text(unitManager.formatWeight(totalVolume))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    Text("TOTAL VOLUME")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    endWorkoutSession(completed: true)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("FINISH WORKOUT")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                // Only show the "Return to Home" button if presented modally
                if isPresentedModally {
                    Button(action: {
                        endWorkoutSession(completed: true)
                        // Dismiss the entire navigation stack by accessing the root controller
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootViewController = windowScene.windows.first?.rootViewController {
                            rootViewController.dismiss(animated: true)
                        }
                    }) {
                        Text("RETURN TO HOME")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color(UIColor.systemBackground))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            // Start celebration animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    showCompletionAnimation = true
                }
            }
        }
    }
    
    var exerciseSection: some View {
        guard currentExerciseIndex < groupedSets.count else {
            return AnyView(EmptyView())
        }
        
        let currentSets = groupedSets[currentExerciseIndex]
        let exerciseName = currentSets.first?.exercise?.name ?? "Exercise"
        
        // Get the max set number for this exercise
        let _ = currentSets.map { $0.setNumber }.max() ?? 0
        
        return AnyView(
            VStack(alignment: .leading, spacing: 16) {
                // Exercise name
                Text(exerciseName)
                    .font(.system(size: 24, weight: .bold))
                
                // Set progress indicator
                HStack {
                    Text(currentSetDisplayText)
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    // Visual set progress indicators
                    HStack(spacing: 6) {
                        ForEach(0..<currentSets.count, id: \.self) { setIdx in
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(
                                    currentSets[setIdx].completed ? .green :
                                    setIdx == currentSetIndex ? .blue : .gray.opacity(0.3)
                                )
                        }
                    }
                }
                
                // Current set
                if currentSetIndex < currentSets.count {
                    FullScreenSetView(
                        workoutSet: currentSets[currentSetIndex],
                        setIndex: currentSetIndex,
                        totalSets: currentSets.count,
                        onCompleteTapped: { reps, weight, time in
                            completeCurrentSet(reps: reps, weight: weight, time: time)
                        }
                    )
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
        )
    }
    
    var progressBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PROGRESS")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    // Filled portion
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.blue)
                        .frame(width: max(0, min(geo.size.width * CGFloat(completedSetsCount) / CGFloat(max(1, workoutSets.count)), geo.size.width)), height: 8)
                        .animation(.spring(response: 0.3), value: completedSetsCount)
                }
            }
            .frame(height: 8)
            
            // Stats
            HStack {
                Text("\(completedSetsCount) sets completed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(workoutSets.count - completedSetsCount) sets remaining")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    var upcomingExercises: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("UPCOMING")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            ForEach(currentExerciseIndex + 1..<min(currentExerciseIndex + 3, groupedSets.count), id: \.self) { index in
                let sets = groupedSets[index]
                let exercise = sets.first?.exercise
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(exercise?.name ?? "Exercise")
                            .font(.headline)
                        
                        Text("\(sets.count) sets")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 30, height: 30)
                        
                        Text("\(index + 1)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }
    
    var controlBar: some View {
        HStack(spacing: 16) {
            // Pause/Resume button
            Button(action: {
                if isTimerRunning {
                    pauseTimer()
                } else {
                    startTimer()
                }
            }) {
                Label(isTimerRunning ? "Pause" : "Resume", systemImage: isTimerRunning ? "pause.fill" : "play.fill")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            // Finish button
            Button(action: {
                endWorkoutSession(completed: true)
                if isPresentedModally {
                    // Dismiss the entire navigation stack by accessing the root controller
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootViewController = windowScene.windows.first?.rootViewController {
                        rootViewController.dismiss(animated: true)
                    }
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Label("Finish", systemImage: "flag.fill")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
    
    var editSetView: some View {
        let currentSets = groupedSets[currentExerciseIndex]
        let currentSet = currentSets[currentSetIndex]
        
        return NavigationView {
            Form {
                Section(header: Text("Weight")) {
                    HStack {
                        Slider(value: $editedWeight, in: 0...500, step: 2.5)
                        Text(unitManager.formatWeight(editedWeight))
                            .frame(width: 90)
                    }
                }
                
                Section(header: Text("Reps")) {
                    Stepper("\(editedReps) reps", value: $editedReps, in: 0...100)
                }
                
                if currentSet.timeSeconds > 0 {
                    Section(header: Text("Duration")) {
                        HStack {
                            Slider(value: Binding(
                                get: { Double(editedTime) },
                                set: { editedTime = $0 }
                            ), in: 0...300, step: 5)
                            Text("\(Int(editedTime)) sec")
                                .frame(width: 70)
                        }
                    }
                }
            }
            .navigationBarTitle("Edit Set", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    showingSetEditor = false
                },
                trailing: Button("Save") {
                    updateCurrentSet()
                    showingSetEditor = false
                }
            )
        }
    }
    
    var exerciseCompletionView: some View {
        let currentSets = groupedSets[currentExerciseIndex]
        let exercise = currentSets.first?.exercise
        
        return ZStack {
            Color.black
                .opacity(0.9)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                // Success animation
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.green)
                    .padding()
                
                // Text
                VStack(spacing: 16) {
                    Text("EXERCISE COMPLETE")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(exercise?.name ?? "Exercise")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Stats
                VStack(spacing: 16) {
                    HStack(spacing: 40) {
                        VStack {
                            Text("\(currentSets.count)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                            Text("SETS")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        // Calculate total reps
                        let totalReps = currentSets.reduce(0) { $0 + $1.reps }
                        VStack {
                            Text("\(totalReps)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                            Text("REPS")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 20)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                
                Spacer()
                
                // Continue button
                Button(action: {
                    moveToNextExercise()
                    withAnimation {
                        showingExerciseCompletion = false
                    }
                }) {
                    HStack {
                        Text("CONTINUE")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
    
    var restTimerOverlay: some View {
        ZStack {
            Color.black
                .opacity(0.9)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // Timer
                VStack(spacing: 8) {
                    Text("REST")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(restTimeRemaining)s")
                        .font(.system(size: 96, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .frame(height: 120)
                        .contentTransition(.numericText())
                        .animation(.spring(duration: 0.3), value: restTimeRemaining)
                }
                .padding(.top, 40)
                
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 12)
                        
                        // Filled portion - assuming 60 seconds default
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue)
                            .frame(width: max(0, min(geo.size.width * CGFloat(60 - restTimeRemaining) / 60.0, geo.size.width)), height: 12)
                            .animation(.linear, value: restTimeRemaining)
                    }
                }
                .frame(height: 12)
                .padding(.horizontal)

                // Get info about the next set
                if currentExerciseIndex < groupedSets.count && currentSetIndex < groupedSets[currentExerciseIndex].count {
                    let currentSets = groupedSets[currentExerciseIndex]
                    let currentSet = currentSets[currentSetIndex]
                    let exerciseName = currentSet.exercise?.name ?? "Exercise"
                    
                    VStack(alignment: .center, spacing: 16) {
                        Text("UP NEXT")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                        
                        Text(exerciseName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text("SET")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(currentSetIndex + 1)/\(currentSets.count)")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                            }
                            
                            if currentSet.weight > 0 {
                                VStack {
                                    Text("WEIGHT")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text(unitManager.formatWeight(currentSet.weight))
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                }
                            }
                            
                            VStack {
                                Text("REPS")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(currentSet.reps)")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        if let previousSet = getPreviousSet() {
                            if previousSet.weight > 0 || previousSet.reps > 0 {
                                VStack(spacing: 4) {
                                    Text("LAST SET")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(unitManager.formatWeight(previousSet.weight)) × \(previousSet.reps) reps")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        restTimeRemaining = max(1, restTimeRemaining + 30)
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("ADD 30 SECONDS")
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        stopRestTimer()
                    }) {
                        HStack {
                            Image(systemName: "forward.fill")
                            Text("SKIP REST")
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
    
    // Helper function to get the previous set
    private func getPreviousSet() -> WorkoutSet? {
        guard currentExerciseIndex < groupedSets.count,
              currentSetIndex > 0,
              currentSetIndex < groupedSets[currentExerciseIndex].count else {
            return nil
        }
        
        let currentSets = groupedSets[currentExerciseIndex]
        
        // Simply return the previous set in the array
        return currentSets[currentSetIndex - 1]
    }
    
    // MARK: - Helper Functions
    
    func prepareToEditSet(_ set: WorkoutSet) {
        editedWeight = set.weight
        editedReps = set.reps
        editedTime = set.timeSeconds
        showingSetEditor = true
    }
    
    func startRestTimer() {
        restTimeRemaining = 60
        showingRestTimer = true
        
        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.restTimeRemaining > 0 {
                self.restTimeRemaining -= 1
            } else {
                self.stopRestTimer()
            }
        }
    }
    
    func stopRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
        withAnimation {
            showingRestTimer = false
        }
    }
    
    // MARK: - Computed Properties
    
    var completedSetsCount: Int {
        return workoutSets.filter { $0.completed }.count
    }
    
    var currentSetDisplayText: String {
        guard currentExerciseIndex < groupedSets.count,
              currentSetIndex < groupedSets[currentExerciseIndex].count else {
            return "Set"
        }
        
        let currentSets = groupedSets[currentExerciseIndex]
        
        // Use array indices for set display rather than setNumber
        return "SET \(currentSetIndex + 1) OF \(currentSets.count)"
    }
    
    // MARK: - Core Functions
    
    func startWorkoutSession() {
        // Start the timer
        startTimer()
        
        // Create a new WorkoutSession
        let session = WorkoutSession(context: dataManager.context)
        session.id = UUID()
        session.startTime = Date()
        session.completed = false
        session.workout = workout
        self.workoutSession = session
        
        // Set workout start time
        workout.startTime = Date()
        dataManager.saveContext()
        
        // Load workout sets
        loadWorkoutSets()
    }
    
    func loadWorkoutSets() {
        // Get all sets for this workout
        guard let sets = workout.sets?.allObjects as? [WorkoutSet] else {
            return
        }
        
        // Don't sort by exercise name - let's preserve the order as is
        workoutSets = sets
        
        // Group sets by exercise but maintain original order
        var grouped: [[WorkoutSet]] = []
        var currentExerciseID: NSManagedObjectID? = nil
        var currentGroup: [WorkoutSet] = []
        
        for set in workoutSets {
            let exerciseID = set.exercise?.objectID
            
            if exerciseID != currentExerciseID {
                if !currentGroup.isEmpty {
                    // No sorting - keep original order
                    grouped.append(currentGroup)
                    currentGroup = []
                }
                currentExerciseID = exerciseID
            }
            
            currentGroup.append(set)
        }
        
        if !currentGroup.isEmpty {
            // No sorting - keep original order
            grouped.append(currentGroup)
        }
        
        groupedSets = grouped
        
        // Log the set order for debugging
        print("Workout sets loaded. Total exercises: \(groupedSets.count)")
        for (i, exerciseGroup) in groupedSets.enumerated() {
            let exerciseName = exerciseGroup.first?.exercise?.name ?? "Unknown"
            print("Exercise \(i+1): \(exerciseName)")
            for (j, set) in exerciseGroup.enumerated() {
                print("  Set \(j+1): setNumber = \(set.setNumber)")
            }
        }
        
        // Ensure we start with the first exercise and first set
        currentExerciseIndex = 0
        currentSetIndex = 0
    }
    
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                self.elapsedTime = Date().timeIntervalSince(self.startTime)
            }
        }
        isTimerRunning = true
    }
    
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }
    
    func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func completeCurrentSet(reps: Int16, weight: Double, time: Double) {
        guard currentExerciseIndex < groupedSets.count,
              currentSetIndex < groupedSets[currentExerciseIndex].count else {
            return
        }
        
        // Mark the current set as completed
        let currentSets = groupedSets[currentExerciseIndex]
        let currentSet = currentSets[currentSetIndex]
        currentSet.completed = true
        currentSet.reps = reps
        
        // Convert weight to metric if needed before saving
        if unitManager.unitSystem == .imperial {
            currentSet.weight = unitManager.convertWeight(weight, from: .imperial, to: .metric)
        } else {
            currentSet.weight = weight
        }
        
        currentSet.timeSeconds = time
        
        // Save changes
        dataManager.saveContext()
        
        // Simply move to the next set in the array
        if currentSetIndex < currentSets.count - 1 {
            // More sets in this exercise - show rest timer and move to next set
            startRestTimer()
            currentSetIndex += 1
        } else if currentExerciseIndex < groupedSets.count - 1 {
            // All sets for current exercise are completed, move to next exercise
            withAnimation {
                showingExerciseCompletion = true
            }
        } else {
            // This was the last set of the last exercise
            // Show workout completion screen instead of dismissing
            endWorkoutSession(completed: true)
            withAnimation {
                showingWorkoutCompletion = true
            }
        }
    }
    
    func moveToNextExercise() {
        if currentExerciseIndex < groupedSets.count - 1 {
            currentExerciseIndex += 1
            currentSetIndex = 0
        }
    }
    
    func updateCurrentSet() {
        guard currentExerciseIndex < groupedSets.count,
              currentSetIndex < groupedSets[currentExerciseIndex].count else {
            return
        }
        
        let currentSet = groupedSets[currentExerciseIndex][currentSetIndex]
        
        // Convert weight to metric if needed before saving
        if unitManager.unitSystem == .imperial {
            currentSet.weight = unitManager.convertWeight(editedWeight, from: .imperial, to: .metric)
        } else {
            currentSet.weight = editedWeight
        }
        
        currentSet.reps = editedReps
        currentSet.timeSeconds = editedTime
        
        dataManager.saveContext()
    }
    
    func endWorkoutSession(completed: Bool) {
        // Stop the timer
        pauseTimer()
        
        // Update workout timing
        workout.endTime = Date()
        if let startTime = workout.startTime {
            workout.duration = Date().timeIntervalSince(startTime)
        }
        
        // Update the WorkoutSession if it exists
        if let session = workoutSession {
            session.duration = elapsedTime
            
            // We'll attempt to set the completion status
            // Check if 'completed' is a valid key
            if session.entity.attributesByName["completed"] != nil {
                session.setValue(completed, forKey: "completed")
            }
            
            // Link workout sets to the session if there's a "sets" relationship
            if session.entity.relationshipsByName["sets"] != nil {
                for set in workoutSets {
                    let sets = session.mutableSetValue(forKey: "sets")
                    sets.add(set)
                }
            }
        }
        
        // Create or update exercise history records for this workout completion
        if completed {
            saveExerciseHistory()
        }
        
        // Save changes
        dataManager.saveContext()
    }
    
    // Create or update exercise history records for this workout completion
    private func saveExerciseHistory() {
        guard let user = workout.user else { return }
        
        let completionDate = Date() // Use current date as the completion date
        workout.date = completionDate // Update workout date to now
        
        // Group completed sets by exercise
        var exerciseSets: [Exercise: [WorkoutSet]] = [:]
        
        for set in workoutSets {
            if set.completed, let exercise = set.exercise {
                if exerciseSets[exercise] == nil {
                    exerciseSets[exercise] = []
                }
                exerciseSets[exercise]?.append(set)
            }
        }
        
        // For each exercise, create or update history record with a unique workout ID
        let workoutUniqueID = UUID().uuidString
        
        for (exercise, sets) in exerciseSets {
            // Calculate stats for this exercise in this workout
            let totalSets = Int16(sets.count)
            
            var maxWeight = 0.0
            var repsAtMaxWeight: Int16 = 0
            var totalVolume = 0.0
            
            for set in sets {
                // Calculate total volume
                let setVolume = set.weight * Double(set.reps)
                totalVolume += setVolume
                
                // Track max weight
                if set.weight > maxWeight {
                    maxWeight = set.weight
                    repsAtMaxWeight = set.reps
                }
            }
            
            // Create a new history record for this workout completion (don't merge with existing records)
            let history = ExerciseHistory(context: dataManager.context)
            history.id = UUID()
            history.user = user
            history.exercise = exercise
            history.date = completionDate
            history.maxWeight = maxWeight
            history.repsAtMaxWeight = repsAtMaxWeight
            history.totalVolume = totalVolume
            history.totalSets = totalSets
            history.workoutID = workoutUniqueID // Store workout ID to track unique workouts
        }
    }
}

// MARK: - Supporting Views

struct FullScreenSetView: View {
    let workoutSet: WorkoutSet
    let onCompleteTapped: (Int16, Double, Double) -> Void
    var setIndex: Int
    var totalSets: Int
    @EnvironmentObject var unitManager: UnitManager
    
    // Add device size detection
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var actualReps: Int16
    @State private var actualWeight: Double
    @State private var actualTime: Double
    @State private var showTimer: Bool = false
    @State private var timerRunning: Bool = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timerStartTime: Date?
    @State private var timer: Timer?
    
    init(workoutSet: WorkoutSet, setIndex: Int, totalSets: Int, onCompleteTapped: @escaping (Int16, Double, Double) -> Void) {
        self.workoutSet = workoutSet
        self.setIndex = setIndex
        self.totalSets = totalSets
        self.onCompleteTapped = onCompleteTapped
        self._actualReps = State(initialValue: workoutSet.reps)
        
        // Initialize with weight properly converted from metric to current unit system
        // This will be done at runtime with the EnvironmentObject
        self._actualWeight = State(initialValue: workoutSet.weight)
        
        self._actualTime = State(initialValue: workoutSet.timeSeconds)
    }
    
    var body: some View {
        VStack {
            // Add flexible spacer to push content to center
            Spacer(minLength: 50)  // Reduced from 80 for smaller screens
            
            VStack(spacing: 20) {  // Reduced spacing from 30 for smaller screens
                // Exercise info header
                VStack(spacing: 12) {  // Reduced spacing from 16 for smaller screens
                    Text(workoutSet.exercise?.name ?? "Exercise")
                        .font(.system(size: adaptiveFontSize(28), weight: .bold))  // Reduced from 32 for smaller screens
                        .multilineTextAlignment(.center)
                    
                    Text("SET \(setIndex + 1) OF \(totalSets)")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                // Target information
                VStack(spacing: 8) {
                    Text("TARGET")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Group {
                        if workoutSet.weight > 0 {
                            Text(unitManager.formatWeight(workoutSet.weight))
                                .font(.system(size: adaptiveFontSize(22), weight: .medium))  // Reduced from 24 for smaller screens
                        }
                        
                        if workoutSet.reps > 0 {
                            Text("\(workoutSet.reps) reps")
                                .font(.system(size: adaptiveFontSize(22), weight: .medium))  // Reduced from 24 for smaller screens
                        }
                        
                        if workoutSet.timeSeconds > 0 {
                            Text(workoutSet.formattedTime)
                                .font(.system(size: adaptiveFontSize(22), weight: .medium))  // Reduced from 24 for smaller screens
                        }
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                if showTimer && workoutSet.timeSeconds > 0 {
                    // Timer view for timed exercises
                    timerView
                } else {
                    ScrollView {
                        VStack(spacing: 20) {  // Reduced spacing from 25 for smaller screens
                            // Actual weight adjustment (if applicable)
                            if workoutSet.weight > 0 {
                                VStack(spacing: 12) {  // Reduced spacing from 16 for smaller screens
                                    Text("WEIGHT")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    HStack(spacing: 30) {  // Reduced spacing from 40 for smaller screens
                                        Button(action: {
                                            if actualWeight >= 2.5 {
                                                actualWeight -= 2.5
                                            }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.system(size: adaptiveFontSize(38)))  // Reduced from 44 for smaller screens
                                                .foregroundColor(.blue)
                                        }
                                        
                                        Text(String(format: "%.1f", actualWeight))
                                            .font(.system(size: adaptiveFontSize(38), weight: .bold))  // Reduced from 44 for smaller screens
                                            .minimumScaleFactor(0.6)  // Allow text to scale down if needed
                                            .lineLimit(1)
                                        
                                        Button(action: {
                                            actualWeight += 2.5
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: adaptiveFontSize(38)))  // Reduced from 44 for smaller screens
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    
                                    Text(unitManager.unitSystem.weightUnit)
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                            
                            // Actual reps adjustment
                            if workoutSet.reps > 0 {
                                VStack(spacing: 12) {  // Reduced spacing from 16 for smaller screens
                                    Text("REPS")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    HStack(spacing: 30) {  // Reduced spacing from 40 for smaller screens
                                        Button(action: {
                                            if actualReps > 0 {
                                                actualReps -= 1
                                            }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.system(size: adaptiveFontSize(38)))  // Reduced from 44 for smaller screens
                                                .foregroundColor(.blue)
                                        }
                                        
                                        Text("\(actualReps)")
                                            .font(.system(size: adaptiveFontSize(38), weight: .bold))  // Reduced from 44 for smaller screens
                                            .minimumScaleFactor(0.6)  // Allow text to scale down if needed
                                            .lineLimit(1)
                                        
                                        Button(action: {
                                            actualReps += 1
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: adaptiveFontSize(38)))  // Reduced from 44 for smaller screens
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                            
                            // Time adjustment or button
                            if workoutSet.timeSeconds > 0 {
                                Button(action: {
                                    withAnimation {
                                        showTimer = true
                                    }
                                    startTimer()
                                }) {
                                    HStack {
                                        Image(systemName: "timer")
                                        Text("START TIMER (\(Int(workoutSet.timeSeconds))s)")
                                    }
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .padding(.horizontal)
            
            // Add flexible spacer to push content to center
            Spacer(minLength: 50)  // Reduced from 80 for smaller screens
            
            // Confirm button
            Button(action: {
                if timer != nil {
                    stopTimer()
                }
                onCompleteTapped(actualReps, actualWeight, actualTime > 0 ? actualTime : workoutSet.timeSeconds)
            }) {
                Text("COMPLETE SET")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 14)  // Increased vertical padding
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)  // Increased horizontal padding
            .padding(.bottom, getSafeAreaBottomPadding())  // Dynamic bottom padding based on device
        }
        .onAppear {
            // Convert weight from metric to current unit system when view appears
            if unitManager.unitSystem == .imperial {
                actualWeight = unitManager.convertWeight(workoutSet.weight, from: .metric, to: .imperial)
            }
        }
        // Add responsive scaling for different device sizes
        .environment(\.horizontalSizeClass, .compact) // Force compact layout on all devices
    }
    
    private var timerView: some View {
        VStack(spacing: 16) {  // Reduced spacing from 20 for smaller screens
            // Time display
            Text(formatElapsedTime())
                .font(.system(size: adaptiveFontSize(70), weight: .bold, design: .monospaced))  // Reduced from 80 for smaller screens
                .foregroundColor(timerRunning ? .blue : .orange)
                .frame(height: 90)  // Reduced from 100 for smaller screens
                .contentTransition(.numericText())
                .animation(.spring(duration: 0.3), value: elapsedTime)
                .minimumScaleFactor(0.7)  // Allow text to scale down if needed
            
            // Progress indicator
            if workoutSet.timeSeconds > 0 {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 12)
                        
                        // Filled portion
                        RoundedRectangle(cornerRadius: 6)
                            .fill(elapsedTime >= workoutSet.timeSeconds ? Color.green : Color.blue)
                            .frame(width: max(0, min(geo.size.width * CGFloat(elapsedTime) / CGFloat(workoutSet.timeSeconds), geo.size.width)), height: 12)
                            .animation(.linear, value: elapsedTime)
                    }
                }
                .frame(height: 12)
                .padding(.horizontal, 4)  // Added horizontal padding
            }
            
            // Controls
            HStack(spacing: 12) {  // Reduced spacing from 20 for smaller screens
                Button(action: {
                    if timerRunning {
                        pauseTimer()
                    } else {
                        startTimer()
                    }
                }) {
                    HStack {
                        Image(systemName: timerRunning ? "pause.fill" : "play.fill")
                        Text(timerRunning ? "PAUSE" : "RESUME")
                    }
                    .font(.headline)
                    .padding(.vertical, 12)  // Specified vertical padding
                    .padding(.horizontal, 8)  // Added horizontal padding
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    resetTimer()
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("RESET")
                    }
                    .font(.headline)
                    .padding(.vertical, 12)  // Specified vertical padding
                    .padding(.horizontal, 8)  // Added horizontal padding
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            
            Button(action: {
                stopTimer()
                actualTime = elapsedTime
                withAnimation {
                    showTimer = false
                }
            }) {
                Text("DONE")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)  // Specified vertical padding
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding(.top, 8)  // Added top padding
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func formatElapsedTime() -> String {
        let totalSeconds = Int(elapsedTime)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startTimer() {
        if timerStartTime == nil {
            timerStartTime = Date().addingTimeInterval(-elapsedTime)
        } else if !timerRunning {
            // Adjust the start time to account for the pause
            timerStartTime = Date().addingTimeInterval(-elapsedTime)
        }
        
        timerRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let startTime = timerStartTime {
                elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
        timerRunning = false
    }
    
    private func stopTimer() {
        pauseTimer()
        timerRunning = false
    }
    
    private func resetTimer() {
        stopTimer()
        elapsedTime = 0
        timerStartTime = nil
    }
    
    // Helper function to get appropriate bottom padding based on device
    private func getSafeAreaBottomPadding() -> CGFloat {
        // For devices with a home indicator (like iPhone X and later), add more padding
        // This is a simple estimation - in a production app, you'd use UIDevice and other methods
        let hasHomeIndicator = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0 > 0
        return hasHomeIndicator ? 30 : 20
    }
    
    // Helper function to get font size adjusted for device size
    private func adaptiveFontSize(_ size: CGFloat) -> CGFloat {
        // Use smaller font sizes on compact devices like iPhone 12/13
        let baseSize = UIScreen.main.bounds.width < 390 ? size * 0.85 : size
        return horizontalSizeClass == .compact ? baseSize : baseSize * 1.2
    }
}

struct SetRowView: View {
    let workoutSet: WorkoutSet
    let onCompleteTapped: () -> Void
    var setIndex: Int? = nil
    
    var body: some View {
        HStack {
            // Set information
            setInfoView
            
            Spacer()
            
            // Status and action buttons
            statusView
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
    
    private var setInfoView: some View {
        VStack(alignment: .leading) {
            // Use provided index+1 if available, fallback to setNumber
            Text("Set \(setIndex != nil ? "\(setIndex! + 1)" : "\(workoutSet.setNumber)")")
                .font(.headline)
            
            Text(workoutSet.setDescription)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var statusView: some View {
        Group {
            if workoutSet.completed {
                completedSetView
            } else {
                currentSetView
            }
        }
    }
    
    private var completedSetView: some View {
        Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.green)
            .font(.title2)
    }
    
    private var currentSetView: some View {
        HStack(spacing: 12) {
            Button(action: onCompleteTapped) {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.green)
                    .clipShape(Circle())
            }
        }
    }
}

// MARK: - Preview

struct SafeAreaBottomInsetModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content.safeAreaInset(edge: .bottom) { 
                Color.clear.frame(height: 20) 
            }
        } else {
            content.padding(.bottom, 20)
        }
    }
}

// MARK: - Tab Bar Modifier

struct HiddenTabBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .toolbar(.hidden, for: .tabBar)
        } else {
            content
                .padding(.bottom, 20) // Add padding at the bottom to avoid button overlap
        }
    }
}

extension View {
    func hiddenTabBar() -> some View {
        self.modifier(HiddenTabBarModifier())
    }
}

