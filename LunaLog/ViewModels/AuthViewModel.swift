import Foundation
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let authService = AuthService.shared

    init() {
        checkAuthState()
    }

    func checkAuthState() {
        isLoggedIn = authService.isLoggedInOrGuest
    }

    // MARK: - Guest
    func continueAsGuest() {
        authService.continueAsGuest()
        isLoggedIn = true
    }

    // MARK: - Google Sign-In
    func signInWithGoogle() {
        isLoading = true
        errorMessage = nil

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            errorMessage = S.authErrorGeneral
            isLoading = false
            return
        }

        authService.signInWithGoogle(presenting: rootVC) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success:
                self.isLoggedIn = true
                DataService.shared.mergeLocalDataToCloud()
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    // MARK: - Sign Out
    func signOut() {
        do {
            try authService.signOut()
            isLoggedIn = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - User Info
    var displayName: String? { authService.displayName }
    var email: String? { authService.email }
    var photoURL: URL? { authService.photoURL }
    var isGuest: Bool { authService.isGuest }

    var loginProviderDisplayName: String {
        guard let provider = authService.loginProvider else {
            return authService.isGuest ? S.authGuest : ""
        }
        switch provider {
        case "google.com": return "Google"
        default: return provider
        }
    }
}
