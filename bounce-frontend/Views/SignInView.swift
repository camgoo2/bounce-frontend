//
//  SignInView.swift
//  bounce-frontend
//
//  Created by Cameron Goodhue on 16/09/2025.
//

// SignInView.swift
import SwiftUI

struct SignInView: View {
    @State private var username: String = ""
    @State private var fullName: String = "" // Used only for registration
    @State private var isRegistering = false
    @State private var message: String?
    @State private var navigateToHome = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to Bounce")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if isRegistering {
                    TextField("Full Name", text: $fullName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                if let message = message {
                    Text(message)
                        .foregroundColor(message.contains("successful") ? .green : .red)
                }

                Button(action: isRegistering ? register : login) {
                    Text(isRegistering ? "Register" : "Login")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .disabled((isRegistering && fullName.isEmpty) || username.isEmpty)

                Button(action: { isRegistering.toggle() }) {
                    Text(isRegistering ? "Already have an account? Login" : "Need an account? Register")
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
            }
            .navigationTitle("Sign In")
            .padding()
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
            }
        }
    }

    private func register() {
        APIService.shared.createUser(username: username, fullName: fullName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    if let userId = user["id"] as? Int {
                        // Store the user_id in UserDefaults
                        UserDefaults.standard.set(userId, forKey: "currentUserId")
                    }
                    message = "Registration successful! Redirecting... User ID: \(user["id"] ?? "N/A")"
                    username = ""
                    fullName = ""
                    isRegistering = false
                    navigateToHome = true
                case .failure(let error):
                    message = "Error: \(error.localizedDescription)"
                }
            }
        }
    }

    private func login() {
        let user = ["username": username]
        guard let url = URL(string: "https://dbe4650a6a5b.ngrok-free.app/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: user)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    message = "Error: \(error.localizedDescription)"
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    message = "Invalid credentials or server error"
                    return
                }
                if let data = data, let userData = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let userId = userData["id"] as? Int {
                    UserDefaults.standard.set(userId, forKey: "currentUserId")
                }
                message = "Login successful!"
                navigateToHome = true
            }
        }.resume()
    }
}

#Preview {
    SignInView()
}
