import SwiftUI

struct ProfileInfoCard: View {
    let user: User?
    let formatHeight: (Double) -> String
    let formatWeight: (Double) -> String
    let formattedBMI: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card header
            Text("Personal Information")
                .font(.headline)
                .cardHeader(color: .blue)
            
            // Card content
            VStack(spacing: 0) {
                Divider()
                
                infoRow(title: "Name", value: user?.name ?? "Not set")
                
                Divider()
                
                if let age = user?.age, age > 0 {
                    infoRow(title: "Age", value: "\(age) years")
                    Divider()
                }
                
                if let height = user?.height, height > 0 {
                    infoRow(
                        title: "Height", 
                        value: formatHeight(height)
                    )
                    Divider()
                }
                
                if let weight = user?.weight, weight > 0 {
                    infoRow(
                        title: "Weight", 
                        value: formatWeight(weight)
                    )
                    Divider()
                }
                
                // BMI calculation
                if user?.height ?? 0 > 0 && user?.weight ?? 0 > 0 {
                    infoRow(title: "BMI", value: formattedBMI)
                }
            }
            .padding(.vertical, 8)
        }
        .cardStyle()
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
} 