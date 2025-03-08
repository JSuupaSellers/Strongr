//
//  WorkoutCard.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI

struct WorkoutCard: View {
    var workout: Workout
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name ?? "Workout")
                    .fontWeight(.semibold)
                
                if let date = workout.date {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let sets = workout.sets as? Set<WorkoutSet>, !sets.isEmpty {
                    Text("\(sets.count) exercise sets")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(.systemGray4))
                .font(.footnote)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
} 