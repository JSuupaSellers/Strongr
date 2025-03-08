//
//  ExerciseRow.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI

// This component is no longer needed since we're using a custom card in ExercisesView
// However, we'll keep it with an improved design to maintain compatibility
struct ExerciseRow: View {
    var exercise: Exercise
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon based on category
            ZStack {
                Circle()
                    .fill(categoryColor(for: exercise.category ?? "").opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: categoryIcon(for: exercise.category ?? ""))
                    .font(.system(size: 20))
                    .foregroundColor(categoryColor(for: exercise.category ?? ""))
            }
            
            // Exercise details
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name ?? "Exercise")
                    .font(.headline)
                
                HStack(spacing: 8) {
                    if let category = exercise.category, !category.isEmpty {
                        Text(category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let muscleGroup = exercise.targetMuscleGroup, !muscleGroup.isEmpty {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(muscleGroup)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func categoryIcon(for category: String) -> String {
        switch category {
            case "Strength": return "dumbbell.fill"
            case "Cardio": return "heart.fill"
            case "Bodyweight": return "figure.walk"
            case "Stretching": return "figure.mixed.cardio"
            case "Custom": return "star.fill"
            default: return "tag.fill"
        }
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
} 