import SwiftUI

struct AppInfoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card header
            Text("About")
                .font(.headline)
                .cardHeader(color: .gray)
            
            // App info content
            VStack(spacing: 0) {
                infoRow(title: "Version", value: "1.0.0")
                
                Divider()
                
                Button(action: {
                    // Privacy policy action
                }) {
                    HStack {
                        Text("Privacy Policy")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                
                Divider()
                
                Button(action: {
                    // Terms of service action
                }) {
                    HStack {
                        Text("Terms of Service")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
            }
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