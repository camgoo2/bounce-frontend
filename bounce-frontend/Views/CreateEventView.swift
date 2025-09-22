//
//  CreateEventView.swift
//  bounce-frontend
//
//  Created by Cameron Goodhue on 14/09/2025.
//

// CreateEventView.swift
import SwiftUI

struct CreateEventView: View {
    @Environment(\.presentationMode) var presentationMode //Haven't looked into what this is exactly yet.
    @State private var title: String = ""
    @State private var priority1: String = "" // Field for friend name priority 1
    @State private var priority2: String = "" // Field for friend name priority 2
    @State private var isSubmitting = false
    @State private var message: String? // Use a single message state for consistency
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("What's the plan?", text: $title)
                    TextField("Friend's user name                      (Priority 1)", text: $priority1)
                    TextField("Friend's user name                      (Priority 2)", text: $priority2)
                }
                
                Button(action: submitEvent) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Text("Send Bounce")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background((title.isEmpty || priority1.isEmpty || priority2.isEmpty || isSubmitting) ? Color.gray : Color.blue) //This is a classic ternary operator.
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(title.isEmpty || priority1.isEmpty || priority2.isEmpty || isSubmitting) // Will be disabled if any of these are true. This is a compound boolean expression or validation logic.
                
                if let message = message {
                    Text(message)
                        .foregroundColor(message.contains("Error") ? .red : .green)
                }
            }
            .navigationTitle("Create Bounce")

        }
    }
    
    private func submitEvent() {
        isSubmitting = true
        if let userId = UserDefaults.standard.value(forKey: "currentUserId") as? Int {
            APIService.shared.createEvent(title: title, userId: userId, priority1: priority1, priority2: priority2) { result in
                DispatchQueue.main.async {
                    isSubmitting = false
                    switch result {
                    case .success(let eventResponse):  // ← Now you get a proper struct!
                        message = eventResponse.message  // ← No more as? String casting!
                        title = ""
                        priority1 = ""
                        priority2 = ""
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


