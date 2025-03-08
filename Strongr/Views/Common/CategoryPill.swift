//
//  CategoryPill.swift
//  Strongr
//
//  Created by Joshua Sellers on 3/2/25.
//

import SwiftUI

struct CategoryPill: View {
    var category: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
} 