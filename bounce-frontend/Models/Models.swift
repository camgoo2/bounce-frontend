//
//  Models.swift
//  bounce-frontend
//
//  Created by Cameron Goodhue on 17/09/2025.
//

import Foundation

// MARK: - Auth Models
struct RegisterRequest: Codable {
    let username: String
    let email: String
    let password: String
    let fullName: String

    enum CodingKeys: String, CodingKey {
        case username, email, password
        case fullName = "full_name"
    }
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct AuthResponse: Codable {
    let accessToken: String
    let tokenType: String
    let user: UserResponse

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case user
    }
}

struct UserResponse: Codable {
    let id: Int
    let username: String
    let email: String
    let fullName: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, username, email
        case fullName = "full_name"
        case createdAt = "created_at"
    }
}

// MARK: -Event Request Models
struct CreateEventRequest: Codable {
    let title: String
    let invitees: [InviteeRequest]
    let timeoutMinutes: Int

    enum CodingKeys: String, CodingKey {
        case title, invitees
        case timeoutMinutes = "timeout_minutes"
    }
}

struct InviteeRequest: Codable {
    let userName: String
    let priority: Int
    
    enum CodingKeys: String, CodingKey {
        case userName = "user_name"
        case priority
    }
}

// MARK: -Event Response Models
struct CreateEventResponse: Codable {
    let id: Int
    let title: String
    let creatorId: Int
    let status: String
    let currentInviteeId: Int?
    let timeoutMinutes: Int
    let createdAt: String
    let invitees: [EventInviteeResponse]

    enum CodingKeys: String, CodingKey {
        case id, title, status, invitees
        case creatorId = "creator_id"
        case currentInviteeId = "current_invitee_id"
        case timeoutMinutes = "timeout_minutes"
        case createdAt = "created_at"
    }
}

struct EventInviteeResponse: Codable {
    let inviteeId: Int
    let priority: Int
    let status: String
    let invitedAt: String?
    let respondedAt: String?

    enum CodingKeys: String, CodingKey {
        case priority, status
        case inviteeId = "invitee_id"
        case invitedAt = "invited_at"
        case respondedAt = "responded_at"
    }
}

// Need to through ther below structs to see how they fit in exactly.

struct EventSummary: Codable {
    let id: Int
    let title: String
    let creatorId: Int
    let status: String
    let timeoutMinutes: Int
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, status
        case creatorId = "creator_id"
        case timeoutMinutes = "timeout_minutes"
        case createdAt = "created_at"
    }
}

struct MyInvitationResponse: Codable {
    let id: Int // Invitation ID (EventInvitee.id)
    let event: EventSummary
    let myPriority: Int
    let myStatus: String
    let invitedAt: String?
    let respondedAt: String?
    let isCurrentInvitee: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case event
        case myPriority = "my_priority"
        case myStatus = "my_status"
        case invitedAt = "invited_at"
        case respondedAt = "responded_at"
        case isCurrentInvitee = "is_current_invitee"
    }
}

struct UserInvitationsResponse: Codable {
    let userId: Int
    let username: String
    let pendingInvitations: [MyInvitationResponse]
    let invitationHistory: [MyInvitationResponse]
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username
        case pendingInvitations = "pending_invitations"
        case invitationHistory = "invitation_history"
    }
}

// NEW MODELS FOR SENT INVITATIONS
struct SentInvitationResponse: Codable {
    let event: EventSummary
    let currentInviteeUsername: String?
    let currentInviteeFullName: String?
    let inviteesCount: Int
    
    enum CodingKeys: String, CodingKey {
        case event
        case currentInviteeUsername = "current_invitee_username"
        case currentInviteeFullName = "current_invitee_full_name"
        case inviteesCount = "invitees_count"
    }
}

struct UserSentInvitationsResponse: Codable {
    let userId: Int
    let username: String
    let sentInvitations: [SentInvitationResponse]
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username
        case sentInvitations = "sent_invitations"
    }
}
