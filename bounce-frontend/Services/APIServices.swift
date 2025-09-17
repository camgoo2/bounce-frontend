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
   
    func createEvent(title: String, userId: Int, priority1: String,priority2: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
            let url = baseURL.appendingPathComponent("events")
           
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           
            let body: [String: Any] = [
                "title": title,
                "invitees": [
                    [
                        "user_name": priority1,
                        "priority": 1
                    ],
                    [
                        "user_name": priority2,
                        "priority": 2
                    ]
                    
                ],
                "creator_id": userId
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
    
    func getUserByUsername(username: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
            guard let url = URL(string: "\(baseURL)/users/\(username)") else { return }
           
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
           
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
