import SwiftUI

struct WelcomeSection: View {
    var user: User?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let user = user {
                Text("Welcome back, \(user.name ?? "Athlete")!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Let's crush today's workout!")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            } else {
                Text("Welcome to Strongr!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                
                Text("Start tracking your fitness journey")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.vertical, 4)
    }
} 