import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var cycleManager: CycleManager
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // MARK: - Branding
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: cycleManager.accentGradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                }

                Text("LunaLog")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(S.loginSubtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // MARK: - Sign-In Buttons
            VStack(spacing: 14) {
                // Google Sign-In
                Button(action: { authViewModel.signInWithGoogle() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "g.circle.fill")
                            .font(.title2)
                        Text(S.signInWithGoogle)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray3), lineWidth: 1)
                    )
                }

                // Divider
                HStack(spacing: 12) {
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color(.systemGray4))
                    Text(S.or)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color(.systemGray4))
                }
                .padding(.vertical, 4)

                // Guest Mode
                Button(action: { authViewModel.continueAsGuest() }) {
                    Text(S.continueAsGuest)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 32)
            .disabled(authViewModel.isLoading)

            // MARK: - Loading & Error
            if authViewModel.isLoading {
                ProgressView()
                    .tint(cycleManager.accentColor)
                    .padding(.top, 16)
            }

            if let error = authViewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
            }

            Spacer()
                .frame(height: 50)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
        .environmentObject(CycleManager())
}
