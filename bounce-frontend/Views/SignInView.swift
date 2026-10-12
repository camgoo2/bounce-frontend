//
//  SignInView.swift
//  bounce-frontend
//
//  Created by Cameron Goodhue on 16/09/2025.
//  Updated for JWT Authentication - Oct 2026
//

import SwiftUI

struct SignInView: View {
    @State private var username: String = ""
    @State private var email: String = "" // For registration
    @State private var password: String = ""
    @State private var fullName: String = "" // For registration
    @State private var isRegistering = false
    @State private var message: String?
    @State private var isLoading = false
    @State private var navigateToHome = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to Bounce")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)

                if isRegistering {
                    // Registration Form
                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.horizontal)

                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .padding(.horizontal)

                    TextField("Full Name", text: $fullName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                } else {
                    // Login Form
                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.horizontal)

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }

                if let message = message {
                    Text(message)
                        .foregroundColor(message.contains("successful") ? .green : .red)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }

                Button(action: isRegistering ? register : login) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text(isRegistering ? "Register" : "Login")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(isFormValid() ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(!isFormValid() || isLoading)

                Button(action: {
                    isRegistering.toggle()
                    message = nil
                }) {
                    Text(isRegistering ? "Already have an account? Login" : "Need an account? Register")
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
            }
            .navigationTitle(isRegistering ? "Register" : "Sign In")
            .padding()
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
            }
        }
    }

    private func isFormValid() -> Bool {
        if isRegistering {
            return !username.isEmpty && !email.isEmpty && !password.isEmpty && !fullName.isEmpty
        } else {
            return !username.isEmpty && !password.isEmpty
        }
    }

    private func register() {
        isLoading = true
        message = nil

        APIService.shared.register(
            username: username,
            email: email,
            password: password,
            fullName: fullName
        ) { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case .success(let authResponse):
                    // Save token to Keychain
                    KeychainHelper.shared.saveToken(authResponse.accessToken)

                    // Save user info to UserDefaults
                    UserDefaults.standard.set(authResponse.user.id, forKey: "currentUserId")
                    UserDefaults.standard.set(authResponse.user.username, forKey: "currentUsername")

                    message = "Registration successful! Redirecting..."

                    // Clear form
                    username = ""
                    email = ""
                    password = ""
                    fullName = ""

                    // Navigate to home after brief delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        navigateToHome = true
                    }

                case .failure(let error):
                    message = "Registration failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private func login() {
        isLoading = true
        message = nil

        APIService.shared.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case .success(let authResponse):
                    // Save token to Keychain
                    KeychainHelper.shared.saveToken(authResponse.accessToken)

                    // Save user info to UserDefaults
                    UserDefaults.standard.set(authResponse.user.id, forKey: "currentUserId")
                    UserDefaults.standard.set(authResponse.user.username, forKey: "currentUsername")

                    message = "Login successful! Redirecting..."

                    // Clear form
                    username = ""
                    password = ""

                    // Navigate to home after brief delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        navigateToHome = true
                    }

                case .failure(let error):
                    message = "Login failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    SignInView()
}
