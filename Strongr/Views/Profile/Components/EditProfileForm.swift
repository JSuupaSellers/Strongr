import SwiftUI
import Foundation

struct EditProfileForm: View {
    @Binding var name: String
    @Binding var age: String
    @Binding var height: String
    @Binding var weight: String
    let currentUnitSystem: UnitSystem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card header
            Text("Edit Profile")
                .font(.headline)
                .cardHeader(color: .blue)
            
            // Form fields
            VStack(spacing: 16) {
                // Name field
                formField(title: "Name", value: $name)
                
                // Age field
                formField(title: "Age", value: $age, keyboardType: .numberPad)
                
                // Height field
                heightFormField()
                
                // Weight field
                weightFormField()
            }
            .padding()
        }
        .cardStyle()
    }
    
    private func formField(title: String, value: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextField(title, text: value)
                .keyboardType(keyboardType)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
    
    private func heightFormField() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Height")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                TextField("Height", text: $height)
                    .keyboardType(.decimalPad)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                // Use the unit system from the view model
                let heightUnit = currentUnitSystem == .metric ? "cm" : "in"
                Text(heightUnit)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            }
        }
    }
    
    private func weightFormField() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weight")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                TextField("Weight", text: $weight)
                    .keyboardType(.decimalPad)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                // Use the unit system from the view model
                let weightUnit = currentUnitSystem == .metric ? "kg" : "lbs"
                Text(weightUnit)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            }
        }
    }
} 