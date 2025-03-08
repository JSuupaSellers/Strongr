//
//  ExercisesView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI
import CoreData
import Strongr

// MARK: - Exercises View
struct ExercisesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var exercises: [Exercise] = []
    @State private var searchText: String = ""
    @State private var showingNewExerciseSheet = false
    @State private var selectedCategory: String? = nil
    
    // Categories to filter by
    private let allCategories = ["All", "Strength", "Cardio", "Bodyweight", "Stretching", "Custom"]
    
    var filteredExercises: [Exercise] {
        if searchText.isEmpty && selectedCategory == nil {
            return exercises
        } else {
            return exercises.filter { exercise in
                let matchesSearch = searchText.isEmpty || 
                    (exercise.name?.localizedCaseInsensitiveContains(searchText) ?? false)
                
                let matchesCategory = selectedCategory == nil || selectedCategory == "All" ||
                    exercise.category == selectedCategory
                
                return matchesSearch && matchesCategory
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 16) {
                    // Search and filter section
                    VStack(spacing: 12) {
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            
                            TextField("Search exercises...", text: $searchText)
                                .disableAutocorrection(true)
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(12)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        
                        // Category filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(allCategories, id: \.self) { category in
                                    Button(action: {
                                        if category == "All" {
                                            selectedCategory = nil
                                        } else {
                                            selectedCategory = category
                                        }
                                    }) {
                                        Text(category)
                                            .font(.system(size: 14, weight: .medium))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background((selectedCategory == category || (category == "All" && selectedCategory == nil)) 
                                                ? Color.blue 
                                                : Color(.systemBackground))
                                            .foregroundColor((selectedCategory == category || (category == "All" && selectedCategory == nil)) 
                                                ? .white 
                                                : .primary)
                                            .cornerRadius(20)
                                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Results count
                    HStack {
                        Text("\(filteredExercises.count) \(filteredExercises.count == 1 ? "Exercise" : "Exercises")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // No results message
                    if filteredExercises.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "dumbbell.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.top, 40)
                            
                            Text("No Exercises Found")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(searchText.isEmpty 
                                ? "Try a different category or add a new exercise" 
                                : "Try a different search term or category")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        // Exercise cards
                        LazyVStack(spacing: 12) {
                            ForEach(filteredExercises) { exercise in
                                exerciseCard(for: exercise)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Bottom padding for the floating button
                    Spacer()
                        .frame(height: 80)
                }
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            
            // Add Exercise Button
            Button(action: {
                showingNewExerciseSheet = true
            }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(30)
                    .shadow(color: Color.blue.opacity(0.4), radius: 5, x: 0, y: 3)
                    .padding()
            }
        }
        .navigationTitle("Exercise Library")
        .sheet(isPresented: $showingNewExerciseSheet) {
            NewExerciseView(
                isPresented: $showingNewExerciseSheet,
                onSave: { _ in
                    loadExercises()
                }
            )
        }
        .onAppear {
            loadExercises()
        }
    }
    
    private func exerciseCard(for exercise: Exercise) -> some View {
        NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    // Exercise name and muscle group
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name ?? "Exercise")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let muscleGroup = exercise.targetMuscleGroup, !muscleGroup.isEmpty {
                            Text(muscleGroup)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Category tag
                    if let category = exercise.category {
                        Text(category)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(categoryColor(for: category).opacity(0.15))
                            .foregroundColor(categoryColor(for: category))
                            .cornerRadius(8)
                    }
                }
                
                if let description = exercise.exerciseDescription, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Swipe actions
                HStack {
                    Spacer()
                    
                    Button(action: {
                        if let index = filteredExercises.firstIndex(where: { $0.id == exercise.id }) {
                            deleteExercises(at: IndexSet([index]))
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.8))
                            .padding(8)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category {
            case "Strength": return .blue
            case "Cardio": return .red
            case "Bodyweight": return .green
            case "Stretching": return .purple
            case "Custom": return .orange
            default: return .gray
        }
    }
    
    private func loadExercises() {
        let fetchRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)]
        
        do {
            exercises = try dataManager.context.fetch(fetchRequest)
        } catch {
            print("Error fetching exercises: \(error)")
        }
    }
    
    private func deleteExercises(at offsets: IndexSet) {
        let exercisesToDelete = offsets.map { filteredExercises[$0] }
        
        for exercise in exercisesToDelete {
            dataManager.context.delete(exercise)
        }
        
        dataManager.saveContext()
        loadExercises()
    }
} 