//
//  CreateEventView.swift
//  bounce-frontend
//
//  Created by Cameron Goodhue on 14/09/2025.
//

// CreateEventView.swift
import SwiftUI

struct CreateEventView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String = ""
    @State private var priority1: String = "" // Field for friend name priority 1
    @State private var priority2: String = "" // Field for friend name priority 2
    @State private var isSubmitting = false
    @State private var message: String? // Use a single message state for consistency
    @State private var showSuccessAlert = false // State for showing the alert
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("What's the plan?", text: $title)
                    TextField("Friend's user name                      (Priority 1)", text: $priority1)
                    TextField("Friend's user name                      (Priority 2)", text: $priority2)
                        .keyboardType(.numberPad) // Ensures numeric input
                }
                
                Button(action: submitEvent) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Text("Send Bounce")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background((title.isEmpty || priority1.isEmpty || priority2.isEmpty || isSubmitting) ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(title.isEmpty || priority1.isEmpty || priority2.isEmpty || isSubmitting)
                
                if let message = message {
                    Text(message)
                        .foregroundColor(message.contains("Error") ? .red : .green)
                }
            }
            .navigationTitle("Create Bounce")
            .alert(isPresented: $showSuccessAlert) {
                Alert(title: Text("Success"), message: Text(message ?? "Event successfully created"), dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss() // Dismiss the sheet when OK is tapped
                })
            }
        }
    }
    
    private func submitEvent() {
        isSubmitting = true
        if let userId = UserDefaults.standard.value(forKey: "currentUserId") as? Int {
            APIService.shared.createEvent(title: title, userId: userId, priority1: priority1, priority2: priority2) { result in
                DispatchQueue.main.async {
                    isSubmitting = false
                    switch result {
                    case .success(let data):
                        message = data["message"] as? String
                        title = ""
                        priority1 = ""
                        priority2 = ""
                        // Show alert immediately
                        showSuccessAlert = true
                    case .failure(let error):
                        message = "Error: \(error.localizedDescription)"
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                message = "User not logged in. Please register or login."
                isSubmitting = false
            }
        }
    }
}

#Preview {
    CreateEventView()
}


