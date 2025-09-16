//
//  APIServices.swift
//  bounce-frontend
//
//  Created by Cameron Goodhue on 14/09/2025.
//

import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = URL(string: "https://dbe4650a6a5b.ngrok-free.app")!
   
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
   
    func createEvent(title: String, userId: Int, friendId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("events")
       
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
       
        // Updated request body to include both userId (creator) and friendId (invitee)
        let body: [String: Any] = [
            "title": title,
            "invitees": [
                [
                    "user_id": friendId, // Friend ID as the invitee
                    "priority": 1
                ]
            ],
            "creator_id": userId // Add creator's user_id
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
       
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
           
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
                completion(.failure(error))
                return
            }
           
            completion(.success(()))
        }.resume()
    }
   
    func createUser(username: String, fullName: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("users")
       
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
       
        let body: [String: String] = [
            "username": username,
            "full_name": fullName
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
       
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
           
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
                completion(.failure(error))
                return
            }
           
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
           
            do {
                let result = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                completion(.success(result ?? [:]))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
