import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var appState: AppState
    @FocusState private var focusedField: Field?
    @State private var isPasswordVisible = false

    enum Field {
        case email, password
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer(minLength: 60)

                VStack(spacing: 8) {
                    Text("Welcome Back")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Sign in to continue")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(spacing: 16) {

                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .password
                            }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        Group {
                            if isPasswordVisible {
                                TextField("Password", text: $viewModel.password)
                            } else {
                                SecureField(
                                    "Password",
                                    text: $viewModel.password
                                )
                            }
                        }
                        .focused($focusedField, equals: .password)
                        .submitLabel(.done)

                        Button {
                            withAnimation {
                                isPasswordVisible.toggle()
                            }
                        } label: {
                            Image(
                                systemName: isPasswordVisible
                                    ? "eye.slash.fill" : "eye.fill"
                            )
                            .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }

                if let error = viewModel.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.leading)
                            .font(.callout)
                    }
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Button(action: {
                    focusedField = nil
                    Task { await viewModel.login(appState: appState) }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Login")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(color: .blue.opacity(0.3), radius: 5, y: 3)
                }
                .disabled(viewModel.isLoading)

                Spacer()
            }
            .padding(.horizontal, 20)
            .animation(.easeInOut, value: viewModel.errorMessage)
            .navigationBarHidden(true)
        }
    }
}
