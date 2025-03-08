//
//  ExercisePickerView.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI
import CoreData

struct ExercisePickerView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var selectedExercise: Exercise?
    @Binding var isPresented: Bool
    
    @State private var searchText = ""
    @State private var exercises: [Exercise] = []
    @State private var selectedCategory: String?
    @State private var showingNewExerciseSheet = false
    
    private let categories = ["Strength", "Cardio", "Bodyweight", "Flexibility", "All"]
    
    var filteredExercises: [Exercise] {
        if searchText.isEmpty && selectedCategory == nil {
            return exercises
        } else {
            return exercises.filter { exercise in
                let nameMatch = searchText.isEmpty || (exercise.name?.localizedCaseInsensitiveContains(searchText) ?? false)
                let categoryMatch = selectedCategory == nil || selectedCategory == "All" || exercise.category == selectedCategory
                return nameMatch && categoryMatch
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search exercises", text: $searchText)
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
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                if selectedCategory == category {
                                    selectedCategory = nil
                                } else {
                                    selectedCategory = category
                                }
                            }) {
                                Text(category)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color.blue : Color(.systemGray6))
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                // Exercise list
                List {
                    ForEach(filteredExercises) { exercise in
                        Button(action: {
                            selectedExercise = exercise
                            isPresented = false
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exercise.name ?? "Unnamed Exercise")
                                        .fontWeight(.medium)
                                    
                                    if let category = exercise.category, !category.isEmpty {
                                        Text(category)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                }
                
                // Create new exercise button
                Button(action: {
                    showingNewExerciseSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create New Exercise")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                }
            }
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                loadExercises()
            }
            .sheet(isPresented: $showingNewExerciseSheet) {
                NewExerciseView(isPresented: $showingNewExerciseSheet, onSave: { newExercise in
                    selectedExercise = newExercise
                    isPresented = false
                })
            }
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
} 