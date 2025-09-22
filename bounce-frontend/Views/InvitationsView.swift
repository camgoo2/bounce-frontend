import SwiftUI

struct InvitationsView: View {
    @State private var invitations: UserInvitationsResponse? //The ? simply means it is an Optional in the sense that it can be nil.
    @State private var sentInvitations: UserSentInvitationsResponse?
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
                        // Sent Invitations Section
                        if let sentInvitations = sentInvitations, !sentInvitations.sentInvitations.isEmpty {
                            Section(header: Text("Sent Invitations").foregroundColor(.blue)) {
                                ForEach(sentInvitations.sentInvitations, id: \.event.id) { sentInvitation in
                                    SentInvitationRow(sentInvitation: sentInvitation)
                                }
                            }
                        }
                        
                        // Pending Invitations Section
                        // checking if invitaions is a UserInvitationsResponse
                        // ',' means a "and condition", so both conditions must be true. The '!' is a NOT Operator
                        if let invitations = invitations, !invitations.pendingInvitations.isEmpty {
                            Section(header: Text("Pending Invitations").foregroundColor(.orange)) {
                                ForEach(invitations.pendingInvitations, id: \.event.id) { invitation in
                                    //Pending Invitaion Row is actually a View (Struct)
                                    PendingInvitationRow(invitation: invitation, onResponse: handleResponse) // We need to handle the response invite for Pending invitations.
                                }
                            }
                        }
                        
                        // Invitation History Section
                        if let invitations = invitations, !invitations.invitationHistory.isEmpty {
                            Section(header: Text("Invitation History")) {
                                ForEach(invitations.invitationHistory, id: \.event.id) { invitation in
                                    HistoryInvitationRow(invitation: invitation)
                                }
                            }
                        }
                        
                        // Empty state
                        if (invitations?.pendingInvitations.isEmpty ?? true) &&
                           (invitations?.invitationHistory.isEmpty ?? true) &&
                           (sentInvitations?.sentInvitations.isEmpty ?? true) {
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
            .onAppear(perform: loadAllInvitations) // This function is activated when the InvitationView is loaded.
            .refreshable {
                await refreshInvitations()
            }
        }
    }
    
    private func loadAllInvitations() {
        guard let userId = UserDefaults.standard.value(forKey: "currentUserId") as? Int else {
            errorMessage = "User not logged in"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Load received invitations
        // This is the API service which is called to get the user invitations.
        APIService.shared.getUserInvitations(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.invitations = response
                case .failure(let error):
                    self.errorMessage = "Error loading invitations: \(error.localizedDescription)"
                }
                self.checkLoadingComplete()
            }
        }
        
        // Load sent invitations
        APIService.shared.getUserSentInvitations(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.sentInvitations = response
                case .failure(let error):
                    // Don't overwrite existing error message, just append
                    if self.errorMessage == nil {
                        self.errorMessage = "Error loading sent invitations: \(error.localizedDescription)"
                    }
                }
                self.checkLoadingComplete()
            }
        }
    }
    
    private func checkLoadingComplete() {
        // Check if both API calls are complete
        if invitations != nil && sentInvitations != nil {
            isLoading = false
        } else if errorMessage != nil {
            isLoading = false
        }
    }
    
    private func refreshInvitations() async {
        loadAllInvitations()
    }
    
    private func handleResponse(eventId: Int, status: String) {
        let timestamp = Date()
        print("🐛 handleResponse [\(timestamp)]: eventId=\(eventId), status='\(status)'")
        print("🐛 handleResponse: Current invitations count = \(invitations?.pendingInvitations.count ?? 0)")
        APIService.shared.respondToEvent(eventId: eventId, status: status) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let message = response["message"] as? String {
                        self.successMessage = message
                    }
                    // Reload invitations after responding
                    self.loadAllInvitations()
                    
                    // Clear success message after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.successMessage = nil
                    }
                case .failure(let error):
                    self.errorMessage = "Error responding to invitation: \(error.localizedDescription)"
                }
            }
        }
    }
}

// NEW: Sent Invitation Row
struct SentInvitationRow: View {
    let sentInvitation: SentInvitationResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(sentInvitation.event.title)
                    .font(.headline)
                
                Spacer()
                
                EventStatusBadge(status: sentInvitation.event.status)
            }
            
            HStack {
                if let currentInvitee = sentInvitation.currentInviteeFullName {
                    Text("Currently with: \(currentInvitee)")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                } else {
                    Text("Event completed")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("\(sentInvitation.inviteesCount) invitees")
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
    @State private var hasResponded = false  // Prevent any duplicates
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(invitation.event.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("You're up!")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 12) {  // ← Stack vertically instead of horizontally
                Button(action: {
                    guard !hasResponded else { return }
                    hasResponded = true
                    print("🟢 ACCEPT BUTTON: About to call onResponse with 'accepted'")
                    onResponse(invitation.event.id, "accepted")
                }) {
                    Text("Accept ✅")
                        .frame(maxWidth: .infinity)  // ← Full width buttons
                        .padding()
                        .background(hasResponded ? Color.gray : Color.green)
                        .cornerRadius(8)
                }
                .disabled(hasResponded)
                
                Button(action: {
                    guard !hasResponded else { return }
                    hasResponded = true
                    print("🔴 DECLINE BUTTON: About to call onResponse with 'declined'")
                    onResponse(invitation.event.id, "declined")
                }) {
                    Text("Decline ❌")
                        .frame(maxWidth: .infinity)  // ← Full width buttons
                        .padding()
                        .background(hasResponded ? Color.gray : Color.red)
                        .cornerRadius(8)
                }
                .disabled(hasResponded)
            }
        }
        .padding(.vertical, 4)
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

// NEW: Event Status Badge for sent invitations
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
