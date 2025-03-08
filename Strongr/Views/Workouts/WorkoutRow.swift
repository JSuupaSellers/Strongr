//
//  WorkoutRow.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI
import Strongr

struct WorkoutRow: View {
    var workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.name ?? "Workout")
                    .font(.headline)
                
                Spacer()
                
                statusBadge
            }
            
            if let date = workout.date {
                Text(date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 15) {
                if workout.duration > 0 {
                    Label(workout.formattedDuration, systemImage: "clock")
                        .font(.caption)
                }
                
                Label("\(workout.uniqueExerciseCount) exercises", systemImage: "dumbbell")
                    .font(.caption)
                
                Spacer()
                
                Label("\(workout.setCount) sets", systemImage: "number")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private var statusBadge: some View {
        let status = workout.status
        
        return Text(status.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                status == .completed ? Color.green.opacity(0.2) :
                status == .inProgress ? Color.orange.opacity(0.2) :
                Color.gray.opacity(0.2)
            )
            .foregroundColor(
                status == .completed ? Color.green :
                status == .inProgress ? Color.orange :
                Color.gray
            )
            .cornerRadius(6)
    }
} 