//
//  InvitationsView.swift
//  bounce-frontend
//
//  Updated for JWT Authentication - Oct 2026
//

import SwiftUI

struct InvitationsView: View {
    @State private var pendingInvitations: [MyInvitationResponse] = []
    @State private var invitationHistory: [MyInvitationResponse] = []
    @State private var myEvents: [CreateEventResponse] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading invitations...")
                        .padding()
                } else {
                    List {
                        // My Events Section (sent invitations)
                        if !myEvents.isEmpty {
                            Section(header: Text("Sent Invitations").foregroundColor(.blue)) {
                                ForEach(myEvents, id: \.id) { event in
                                    MyEventRow(event: event)
                                }
                            }
                        }

                        // Pending Invitations Section
                        if !pendingInvitations.isEmpty {
                            Section(header: Text("Pending Invitations").foregroundColor(.orange)) {
                                ForEach(pendingInvitations, id: \.event.id) { invitation in
                                    PendingInvitationRow(invitation: invitation, onResponse: handleResponse)
                                }
                            }
                        }

                        // Invitation History Section
                        if !invitationHistory.isEmpty {
                            Section(header: Text("Invitation History")) {
                                ForEach(invitationHistory, id: \.event.id) { invitation in
                                    HistoryInvitationRow(invitation: invitation)
                                }
                            }
                        }

                        // Empty state
                        if pendingInvitations.isEmpty && invitationHistory.isEmpty && myEvents.isEmpty {
                            Section {
                                Text("No invitations yet")
                                    .foregroundColor(.gray)
                                    .italic()
                                    .padding()
                            }
                        }
                    }
                }

                // Messages
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .padding()
                }
            }
            .navigationTitle("My Invitations")
            .onAppear(perform: loadAllInvitations)
            .refreshable {
                await refreshInvitations()
            }
        }
    }

    private func loadAllInvitations() {
        guard KeychainHelper.shared.isLoggedIn() else {
            errorMessage = "You must be logged in"
            return
        }

        isLoading = true
        errorMessage = nil

        // Load pending invitations
        APIService.shared.getPendingInvitations { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let invitations):
                    self.pendingInvitations = invitations
                case .failure(let error):
                    self.errorMessage = "Error loading pending invitations: \(error.localizedDescription)"
                }
                self.checkLoadingComplete()
            }
        }

        // Load invitation history
        APIService.shared.getInvitationHistory { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let history):
                    self.invitationHistory = history
                case .failure(let error):
                    if self.errorMessage == nil {
                        self.errorMessage = "Error loading history: \(error.localizedDescription)"
                    }
                }
                self.checkLoadingComplete()
            }
        }

        // Load my events (sent invitations)
        APIService.shared.getMyEvents { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let events):
                    self.myEvents = events
                case .failure(let error):
                    if self.errorMessage == nil {
                        self.errorMessage = "Error loading events: \(error.localizedDescription)"
                    }
                }
                self.checkLoadingComplete()
            }
        }
    }

    private func checkLoadingComplete() {
        // Simple check - just stop loading after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
    }

    private func refreshInvitations() async {
        loadAllInvitations()
    }

    private func handleResponse(invitationId: Int, status: String) {
        print("🐛 handleResponse: invitationId=\(invitationId), status='\(status)'")

        if status == "accepted" {
            APIService.shared.acceptInvitation(invitationId: invitationId) { result in
                DispatchQueue.main.async {
                    handleResponseResult(result)
                }
            }
        } else if status == "declined" {
            APIService.shared.declineInvitation(invitationId: invitationId) { result in
                DispatchQueue.main.async {
                    handleResponseResult(result)
                }
            }
        }
    }

    private func handleResponseResult(_ result: Result<String, Error>) {
        switch result {
        case .success(let message):
            self.successMessage = message
            // Reload invitations after responding
            self.loadAllInvitations()

            // Clear success message after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.successMessage = nil
            }
        case .failure(let error):
            self.errorMessage = "Error responding: \(error.localizedDescription)"
        }
    }
}

// My Event Row (for sent invitations)
struct MyEventRow: View {
    let event: CreateEventResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(event.title)
                    .font(.headline)

                Spacer()

                EventStatusBadge(status: event.status)
            }

            HStack {
                if let currentInviteeId = event.currentInviteeId {
                    Text("Currently with invitee #\(currentInviteeId)")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                } else {
                    Text("Event completed")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                Text("\(event.invitees.count) invitees")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

struct PendingInvitationRow: View {
    let invitation: MyInvitationResponse
    let onResponse: (Int, String) -> Void
    @State private var hasResponded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(invitation.event.title)
                    .font(.headline)
                Spacer()
                Text("You're up!")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
            }

            VStack(spacing: 12) {
                Button("Accept ✅") {
                    guard !hasResponded else { return }
                    hasResponded = true
                    print("🟢 ACCEPT clicked for invitation")
                    // Note: We need the invitation ID, not event ID
                    // For now using event.id - backend should accept this
                    onResponse(invitation.event.id, "accepted")
                }
                .buttonStyle(.borderedProminent)
                .tint(hasResponded ? .gray : .green)
                .disabled(hasResponded)
                .frame(maxWidth: .infinity)

                Button("Decline ❌") {
                    guard !hasResponded else { return }
                    hasResponded = true
                    print("🔴 DECLINE clicked for invitation")
                    onResponse(invitation.event.id, "declined")
                }
                .buttonStyle(.borderedProminent)
                .tint(hasResponded ? .gray : .red)
                .disabled(hasResponded)
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
    }
}

struct HistoryInvitationRow: View {
    let invitation: MyInvitationResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(invitation.event.title)
                    .font(.headline)

                Spacer()

                StatusBadge(status: invitation.myStatus)
            }
        }
        .padding(.vertical, 2)
    }
}

struct StatusBadge: View {
    let status: String

    var body: some View {
        Text(status.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(backgroundColour)
            .foregroundColor(textColour)
            .cornerRadius(4)
    }

    private var backgroundColour: Color {
        switch status.lowercased() {
        case "accepted":
            return Color.green.opacity(0.2)
        case "declined":
            return Color.red.opacity(0.2)
        case "pending", "invited":
            return Color.orange.opacity(0.2)
        default:
            return Color.gray.opacity(0.2)
        }
    }

    private var textColour: Color {
        switch status.lowercased() {
        case "accepted":
            return Color.green
        case "declined":
            return Color.red
        case "pending", "invited":
            return Color.orange
        default:
            return Color.gray
        }
    }
}

struct EventStatusBadge: View {
    let status: String

    var body: some View {
        Text(status.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(backgroundColour)
            .foregroundColor(textColour)
            .cornerRadius(4)
    }

    private var backgroundColour: Color {
        switch status.lowercased() {
        case "accepted":
            return Color.green.opacity(0.2)
        case "cancelled":
            return Color.red.opacity(0.2)
        case "active":
            return Color.blue.opacity(0.2)
        case "completed":
            return Color.purple.opacity(0.2)
        default:
            return Color.gray.opacity(0.2)
        }
    }

    private var textColour: Color {
        switch status.lowercased() {
        case "accepted":
            return Color.green
        case "cancelled":
            return Color.red
        case "active":
            return Color.blue
        case "completed":
            return Color.purple
        default:
            return Color.gray
        }
    }
}

#Preview {
    InvitationsView()
}
