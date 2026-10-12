//
//  APIServices.swift
//  bounce-frontend
//
//  Created by Cameron Goodhue on 14/09/2025.
//  Updated for JWT Authentication - Oct 2026
//

import Foundation

class APIService {
    static let shared = APIService()

    // IMPORTANT: Update this URL when ngrok restarts
    private let baseURL = URL(string: "https://7573-34-27-17-156.ngrok-free.app")!

    // MARK: - Authentication

    /// Register a new user account
    func register(username: String, email: String, password: String, fullName: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("api/v1/auth/register")

        let request = RegisterRequest(
            username: username,
            email: email,
            password: password,
            fullName: fullName
        )

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Registration failed"])
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let decoder = JSONDecoder()
                let authResponse = try decoder.decode(AuthResponse.self, from: data)
                completion(.success(authResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    /// Login with username and password
    func login(username: String, password: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("api/v1/auth/login")

        let request = LoginRequest(username: username, password: password)

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Login failed"])
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let decoder = JSONDecoder()
                let authResponse = try decoder.decode(AuthResponse.self, from: data)
                completion(.success(authResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    /// Get current authenticated user info
    func getCurrentUser(completion: @escaping (Result<UserResponse, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("api/v1/auth/me")

        guard var urlRequest = createAuthenticatedRequest(url: url, method: "GET") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to get user info"])
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let decoder = JSONDecoder()
                let user = try decoder.decode(UserResponse.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Events

    /// Create a new event (requires authentication)
    func createEvent(title: String, invitees: [InviteeRequest], timeoutMinutes: Int = 15, completion: @escaping (Result<CreateEventResponse, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("api/v1/events")

        let request = CreateEventRequest(
            title: title,
            invitees: invitees,
            timeoutMinutes: timeoutMinutes
        )

        guard var urlRequest = createAuthenticatedRequest(url: url, method: "POST") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }

        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to create event"])
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let decoder = JSONDecoder()
                let eventResponse = try decoder.decode(CreateEventResponse.self, from: data)
                completion(.success(eventResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    /// Get events created by the authenticated user
    func getMyEvents(completion: @escaping (Result<[CreateEventResponse], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("api/v1/events/my-events")

        guard let urlRequest = createAuthenticatedRequest(url: url, method: "GET") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to get events"])
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let decoder = JSONDecoder()
                let events = try decoder.decode([CreateEventResponse].self, from: data)
                completion(.success(events))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Invitations

    /// Get pending invitations for the authenticated user
    func getPendingInvitations(completion: @escaping (Result<[MyInvitationResponse], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("api/v1/invitations/pending")

        guard let urlRequest = createAuthenticatedRequest(url: url, method: "GET") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to get invitations"])
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let decoder = JSONDecoder()
                let invitations = try decoder.decode([MyInvitationResponse].self, from: data)
                completion(.success(invitations))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    /// Get invitation history for the authenticated user
    func getInvitationHistory(completion: @escaping (Result<[MyInvitationResponse], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("api/v1/invitations/history")

        guard let urlRequest = createAuthenticatedRequest(url: url, method: "GET") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to get history"])
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let decoder = JSONDecoder()
                let invitations = try decoder.decode([MyInvitationResponse].self, from: data)
                completion(.success(invitations))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    /// Accept an invitation
    func acceptInvitation(invitationId: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("api/v1/invitations/\(invitationId)/accept")

        guard let urlRequest = createAuthenticatedRequest(url: url, method: "POST") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to accept invitation"])
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                if let result = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = result["message"] as? String {
                    completion(.success(message))
                } else {
                    completion(.success("Invitation accepted"))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    /// Decline an invitation
    func declineInvitation(invitationId: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("api/v1/invitations/\(invitationId)/decline")

        guard let urlRequest = createAuthenticatedRequest(url: url, method: "POST") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to decline invitation"])
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                if let result = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = result["message"] as? String {
                    completion(.success(message))
                } else {
                    completion(.success("Invitation declined"))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Helper Methods

    /// Create an authenticated URLRequest with JWT token
    private func createAuthenticatedRequest(url: URL, method: String) -> URLRequest? {
        // Get token from Keychain
        guard let token = KeychainHelper.shared.getToken() else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }

    // MARK: - Health Check

    func checkHealth(completion: @escaping (Result<[String: String], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("health")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            do {
                let result = try JSONSerialization.jsonObject(with: data) as? [String: String]
                completion(.success(result ?? [:]))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
