import SwiftUI

struct SettingsCard: View {
    let onUnitsTap: () -> Void
    let onResetOnboardingTap: () -> Void
    let unitSystemDisplayName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card header
            Text("Settings")
                .font(.headline)
                .cardHeader(color: .purple)
            
            // Settings content
            VStack(spacing: 0) {
                // Units setting
                Button(action: onUnitsTap) {
                    HStack {
                        Image(systemName: "ruler")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.purple)
                        
                        Text("Units")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(unitSystemDisplayName)
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding()
                }
                
                Divider()
                
                // Dark Mode setting
                Button(action: {
                    // Toggle theme action
                }) {
                    HStack {
                        Image(systemName: "moon.fill")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.purple)
                        
                        Text("Dark Mode")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("System")
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding()
                }
                
                Divider()
                
                // Notifications setting
                Button(action: {
                    // Privacy action
                }) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.purple)
                        
                        Text("Notifications")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding()
                }
                
                Divider()
                
                // Reset Onboarding (for testing purposes)
                Button(action: onResetOnboardingTap) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.red)
                        
                        Text("Reset Onboarding (Testing)")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding()
                }
            }
        }
        .cardStyle()
    }
} 