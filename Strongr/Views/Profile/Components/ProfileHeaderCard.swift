import SwiftUI

struct ProfileHeaderCard: View {
    let userName: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar image
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(25)
                    .foregroundColor(.white)
            }
            .padding(.top, 16)
            
            // User name
            Text(userName)
                .font(.system(size: 24, weight: .bold))
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
} 