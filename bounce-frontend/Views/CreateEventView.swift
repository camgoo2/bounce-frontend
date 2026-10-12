//
//  CreateEventView.swift
//  bounce-frontend
//
//  Created by Cameron Goodhue on 14/09/2025.
//  Updated for JWT Authentication - Oct 2026
//

import SwiftUI

struct CreateEventView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String = ""
    @State private var priority1: String = "" // Field for friend name priority 1
    @State private var priority2: String = "" // Field for friend name priority 2
    @State private var timeoutMinutes: Int = 15 // Default 15 minutes
    @State private var isSubmitting = false
    @State private var message: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("What's the plan?", text: $title)
                        .autocorrectionDisabled()

                    TextField("Friend's username (Priority 1)", text: $priority1)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    TextField("Friend's username (Priority 2)", text: $priority2)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section(header: Text("Timeout")) {
                    Stepper("Timeout: \(timeoutMinutes) minutes", value: $timeoutMinutes, in: 1...60)
                }

                Button(action: submitEvent) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Text("Send Bounce")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid() ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(!isFormValid() || isSubmitting)

                if let message = message {
                    Text(message)
                        .foregroundColor(message.contains("Error") ? .red : .green)
                }
            }
            .navigationTitle("Create Bounce")
        }
    }

    private func isFormValid() -> Bool {
        return !title.isEmpty && !priority1.isEmpty && !priority2.isEmpty
    }

    private func submitEvent() {
        // Check if user is logged in (has token)
        guard KeychainHelper.shared.isLoggedIn() else {
            message = "You must be logged in to create an event"
            return
        }

        isSubmitting = true
        message = nil

        // Create invitees array
        let invitees = [
            InviteeRequest(userName: priority1, priority: 1),
            InviteeRequest(userName: priority2, priority: 2)
        ]

        // Call new authenticated API
        APIService.shared.createEvent(
            title: title,
            invitees: invitees,
            timeoutMinutes: timeoutMinutes
        ) { result in
            DispatchQueue.main.async {
                isSubmitting = false

                switch result {
                case .success:
                    message = "Event created! First invite sent to \(priority1)"
                    // Clear form
                    title = ""
                    priority1 = ""
                    priority2 = ""
                    timeoutMinutes = 15

                    // Optionally dismiss view after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        presentationMode.wrappedValue.dismiss()
                    }

                case .failure(let error):
                    message = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    CreateEventView()
}
