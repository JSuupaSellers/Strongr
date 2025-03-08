//
//  WorkoutSetRow.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI

struct WorkoutSetRow: View {
    var workoutSet: WorkoutSet
    @EnvironmentObject var unitManager: UnitManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Set number indicator
            ZStack {
                Circle()
                    .fill(workoutSet.completed ? Color.green.opacity(0.2) : Color.blue.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Text("\(workoutSet.setNumber)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(workoutSet.completed ? .green : .blue)
            }
            
            // Exercise details
            VStack(alignment: .leading, spacing: 4) {
                Text(workoutSet.exercise?.name ?? "Unknown")
                    .font(.system(size: 16, weight: .semibold))
                
                HStack(spacing: 12) {
                    // Weight - using UnitManager for formatting
                    if workoutSet.weight > 0 {
                        metricView(
                            value: unitManager.formatWeight(workoutSet.weight),
                            icon: "scalemass.fill"
                        )
                    }
                    
                    // Reps
                    if workoutSet.reps > 0 {
                        metricView(
                            value: "\(workoutSet.reps) reps",
                            icon: "repeat"
                        )
                    }
                    
                    // Time
                    if workoutSet.timeSeconds > 0 {
                        metricView(
                            value: formatTime(workoutSet.timeSeconds),
                            icon: "timer",
                            highlighted: true
                        )
                    }
                }
            }
            
            Spacer()
            
            // Completion indicator
            if workoutSet.completed {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    // Updated helper view for metrics (weight, reps, time)
    private func metricView(value: String, icon: String, highlighted: Bool = false) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(highlighted ? .blue : .secondary)
            
            Text(value)
                .font(.system(size: 12))
                .foregroundColor(highlighted ? .blue : .secondary)
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 6)
        .background(highlighted ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(4)
    }
    
    func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(remainingSeconds)s"
        } else {
            return "\(remainingSeconds)s"
        }
    }
} 