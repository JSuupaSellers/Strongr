//
//  StatCard.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI

struct StatCard: View {
    var title: String
    var value: String
    var icon: String
    var color: Color = .blue
    var change: String = ""
    
    // Initialize with just the required parameters
    init(title: String, value: String, icon: String) {
        self.title = title
        self.value = value
        self.icon = icon
    }
    
    // Initialize with all parameters for backward compatibility
    init(title: String, value: String, icon: String, color: Color, change: String) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.change = change
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // Icon in circular background
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                }
                
                Spacer()
                
                // Change indicator if available
                if !change.isEmpty {
                    Text(change)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(color.opacity(0.15))
                        )
                }
            }
            
            // Value and title
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
} 
