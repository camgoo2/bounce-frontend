//
//  CreateEventView.swift
//  bounce-frontend
//
//  Created by Cameron Goodhue on 14/09/2025.
//

import SwiftUI

struct CreateEventView: View {
    @State private var title: String = ""
    @State private var friendId: Int = 0 // Field for friend ID
    @State private var isSubmitting = false
    @State private var message: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("What's the plan?", text: $title)
                    TextField("Friend ID", value: $friendId, format: .number)
                        .keyboardType(.numberPad) // Ensures numeric input
                }
               
                Button(action: submitEvent) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Text("Send Bounce")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background((title.isEmpty || friendId == 0 || isSubmitting) ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(title.isEmpty || friendId == 0 || isSubmitting)
            }
            .navigationTitle("Create Bounce")
        }
    }
   
    private func submitEvent() {
        isSubmitting = true
        if let userId = UserDefaults.standard.value(forKey: "currentUserId") as? Int {
            APIService.shared.createEvent(title: title, userId: userId, friendId: friendId) { result in // Updated function signature
                DispatchQueue.main.async {
                    isSubmitting = false
                    switch result {
                    case .success:
                        message = "Bounce created and sent! 🎉"
                        title = ""
                        friendId = 0
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
