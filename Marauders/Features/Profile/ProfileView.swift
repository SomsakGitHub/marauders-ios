struct UserProfile: Identifiable, Codable {
    let id: String
    let name: String
    let username: String
    let bio: String
    let avatarURL: String
    let followers: Int
    let following: Int
    let posts: Int
}

import Foundation
import Combine
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var error: String?
    
    func fetchProfile() async {
        isLoading = true
        error = nil
        
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // mock data
            self.profile = UserProfile(
                id: "1",
                name: "SomSak",
                username: "@somsak",
                bio: "iOS Developer 🚀",
                avatarURL: "https://i.pravatar.cc/300",
                followers: 1200,
                following: 300,
                posts: 45
            )
            
        } catch {
            self.error = "Failed to load profile"
        }
        
        isLoading = false
    }
}

struct ProfileView: View {
    
    @StateObject private var viewModel: ProfileViewModel
    
    init(viewModel: ProfileViewModel = ProfileViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                
            } else if let profile = viewModel.profile {
                content(profile)
                
            } else if let error = viewModel.error {
                Text(error)
            }
        }
        .task {
            if viewModel.profile == nil {
                await viewModel.fetchProfile()
            }
        }
    }
    
    private func content(_ profile: UserProfile) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                
                avatarSection(profile)
                infoSection(profile)
                statsSection(profile)
                actionSection()
                
            }
            .padding()
        }
    }
}

#Preview("Loaded State") {
    ProfileView(viewModel: MockProfileViewModel())
}

private func avatarSection(_ profile: UserProfile) -> some View {
    AsyncImage(url: URL(string: profile.avatarURL)) { image in
        image.resizable()
    } placeholder: {
        ProgressView()
    }
    .frame(width: 100, height: 100)
    .clipShape(Circle())
}

private func infoSection(_ profile: UserProfile) -> some View {
    VStack(spacing: 4) {
        Text(profile.name)
            .font(.title2)
            .fontWeight(.bold)
        
        Text(profile.username)
            .foregroundColor(.gray)
        
        Text(profile.bio)
            .font(.subheadline)
    }
}

private func statsSection(_ profile: UserProfile) -> some View {
    HStack(spacing: 24) {
        statItem(value: profile.posts, title: "Posts")
        statItem(value: profile.followers, title: "Followers")
        statItem(value: profile.following, title: "Following")
    }
}

private func statItem(value: Int, title: String) -> some View {
    VStack {
        Text("\(value)")
            .font(.headline)
        Text(title)
            .font(.caption)
            .foregroundColor(.gray)
    }
}

private func actionSection() -> some View {
    HStack(spacing: 12) {
        Button("Follow") {
            // action
        }
        .buttonStyle(.borderedProminent)
        
        Button("Message") {
            // action
        }
        .buttonStyle(.bordered)
    }
}

final class MockProfileViewModel: ProfileViewModel {
    
    override init() {
        super.init()
        
        self.profile = UserProfile(
            id: "1",
            name: "Preview User",
            username: "@preview",
            bio: "This is SwiftUI Preview 🚀",
            avatarURL: "https://i.pravatar.cc/300",
            followers: 999,
            following: 123,
            posts: 42
        )
        
        self.isLoading = false
    }
    
    override func fetchProfile() async {
        // do nothing
    }
}

