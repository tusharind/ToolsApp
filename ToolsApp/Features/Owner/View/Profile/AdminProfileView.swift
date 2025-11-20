import SwiftUI

struct AdminProfileView: View {
    @StateObject private var viewModel = AdminProfileViewModel()
    @EnvironmentObject var appState: AppState
    @State private var showingImageAlert = false
    @State private var newImageUrl = ""
    @State private var showingLogoutAlert = false

    var body: some View {
        NavigationView {
            VStack {
                Text("My Profile")
                    .font(.title)
                    .multilineTextAlignment(.center)

                VStack {
                    if viewModel.isLoading {
                        ProgressView("Loading profile...")
                            .padding()
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 12) {
                            Text(error)
                                .foregroundColor(.red)
                            Button("Retry") {
                                Task { await viewModel.fetchProfile() }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    } else if let profile = viewModel.profile {
                        ScrollView {
                            VStack(spacing: 20) {
                                ZStack(alignment: .bottomTrailing) {
                                    AsyncImage(
                                        url: URL(string: profile.img ?? "")
                                    ) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image.resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                                .shadow(radius: 5)
                                        case .failure:
                                            Image(
                                                systemName:
                                                    "person.crop.circle.fill"
                                            )
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(.gray)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .padding(.top, 20)
                                    
                                }

                                if viewModel.isUpdatingImage {
                                    ProgressView("Updating image...")
                                }

                                Text(profile.username)
                                    .font(.title2)
                                    .bold()

                                VStack(alignment: .leading, spacing: 8) {
                                    Label(
                                        profile.email,
                                        systemImage: "envelope"
                                    )
                                    if let phone = profile.phone {
                                        Label(phone, systemImage: "phone")
                                    }
                                    if let role = profile.role {
                                        Label(
                                            role,
                                            systemImage: "person.text.rectangle"
                                        )
                                    }
                                    if let status = profile.status {
                                        Label(
                                            status,
                                            systemImage: "checkmark.circle"
                                        )
                                    }
                                }
                                .font(.subheadline)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)

                                Button(role: .destructive) {
                                    showingLogoutAlert = true
                                } label: {
                                    Label(
                                        "Logout",
                                        systemImage:
                                            "arrowshape.turn.up.left.fill"
                                    )
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.red)
                                .padding(.top, 20)
                            }
                            .padding()
                        }
                    } else {
                        Text("No profile data found.")
                    }
                }
                .task {
                    await viewModel.fetchProfile()
                }
                .alert(
                    "Update Profile Image",
                    isPresented: $showingImageAlert,
                    actions: {
                        TextField("Image URL", text: $newImageUrl)
                        Button("Update") {
                            Task {
                                await viewModel.updateProfileImage(
                                    with: newImageUrl
                                )
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    },
                    message: {
                        Text("Paste the new image URL below")
                    }
                )
                .alert("Confirm Logout", isPresented: $showingLogoutAlert) {
                    Button("Logout", role: .destructive) {
                        appState.logout()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to log out?")
                }
            }
        }
    }
}
