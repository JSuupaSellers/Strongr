import SwiftUI

struct UnitSystemSelector: View {
    let currentUnitSystem: UnitSystem
    let onMetricSelected: () -> Void
    let onImperialSelected: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            List {
                Button(action: onMetricSelected) {
                    HStack {
                        Text("Metric")
                        
                        Spacer()
                        
                        if currentUnitSystem == .metric {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
                
                Button(action: onImperialSelected) {
                    HStack {
                        Text("Imperial")
                        
                        Spacer()
                        
                        if currentUnitSystem == .imperial {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Select Unit System")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }
} 