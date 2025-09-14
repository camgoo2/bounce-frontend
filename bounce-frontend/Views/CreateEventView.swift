//
//  CreateEventView.swift
//  bounce-frontend
//
//  Created by Cameron Goodhue on 14/09/2025.
//

import SwiftUI

struct CreateEventView: View {
    @State private var title: String = ""
    @State private var user_id: Int = 2 //Default to 2
    @State private var isSubmitting = false
    @State private var message: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("What's the plan?", text: $title)
                    TextField("User ID", value: $user_id, format:.number) // New TextField for friend
                }
               
               
                Button(action: submitEvent) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Text("Send Bounce")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(title.isEmpty || isSubmitting ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(title.isEmpty || isSubmitting)
            }
            .navigationTitle("Create Bounce")
        }
    }
   
    private func submitEvent() {
        isSubmitting = true
        APIService.shared.createEvent(title: title,  user_id: user_id) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success:
                    message = "Bounce created 🎉"
                    title = ""
                case .failure(let error):
                    message = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
