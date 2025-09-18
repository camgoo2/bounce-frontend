//
//  ContentView.swift
//  bounce-frontend
//
//  Created by Cameron Goodhue on 14/09/2025.
//

import SwiftUI

struct HomeView: View {
    @State private var showCreateEventView = false
    @State private var showInvitationsView = false
    @State private var healthMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                if let message = healthMessage {
                    Text(message)
                        .foregroundColor(.green)
                }

                Button(action: checkHealth) {
                    Text("Test API Health")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)

                Button(action: { showCreateEventView = true }) {
                    Text("Create Bounce")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)

                Button(action: { showInvitationsView = true }) {
                    Text("My Invitations")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)

                Spacer()
            }
            .sheet(isPresented: $showCreateEventView) {
                CreateEventView()
            }
            .sheet(isPresented: $showInvitationsView) {
                InvitationsView()
            }
            .navigationTitle("Welcome to Bounce")
        }
    }

    private func checkHealth() {
        APIService.shared.checkHealth { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    healthMessage = data["message"] ?? "API connected successfully!"
                case .failure(let error):
                    healthMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
