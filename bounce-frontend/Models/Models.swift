//
//  InvitationModels.swift
//  bounce-frontend
//
//  Created by Cameron Goodhue on 17/09/2025.
//

import Foundation

// MARK: -Event Request Models
struct CreateEventRequest: Codable {
    let title: String
    let creatorId: Int
    let invitees: [InviteeRequest]
    
    enum CodingKeys: String, CodingKey {
        case title
        case creatorId = "creator_id"
        case invitees
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
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, status, message
        case creatorId = "creator_id"
        case currentInviteeId = "current_invitee_id"
    }
}

// Need to through ther below structs to see how they fit in exactly.

struct EventSummary: Codable {
    let id: Int
    let title: String
    let creatorId: Int
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, status
        case creatorId = "creator_id"
    }
}

struct MyInvitationResponse: Codable {
    let event: EventSummary
    let myPriority: Int
    let myStatus: String
    let invitedAt: String?
    let respondedAt: String?
    let isCurrentInvitee: Bool
    
    enum CodingKeys: String, CodingKey {
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
