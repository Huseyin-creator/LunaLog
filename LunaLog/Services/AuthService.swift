import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AuthService {
    static let shared = AuthService()
    private init() {}

    private let defaults = UserDefaults(suiteName: "group.com.seros.LunaLog") ?? UserDefaults.standard
    private let isGuestKey = "isGuestUser"

    // MARK: - Firebase Configuration
    func configure() {
        FirebaseApp.configure()
    }

    // MARK: - Auth State
    var isAuthenticated: Bool {
        Auth.auth().currentUser != nil
    }

    var isGuest: Bool {
        get { defaults.bool(forKey: isGuestKey) }
        set { defaults.set(newValue, forKey: isGuestKey) }
    }

    var isLoggedInOrGuest: Bool {
        isAuthenticated || isGuest
    }

    var currentUser: User? {
        Auth.auth().currentUser
    }

    var displayName: String? {
        currentUser?.displayName
    }

    var email: String? {
        currentUser?.email
    }

    var photoURL: URL? {
        currentUser?.photoURL
    }

    var loginProvider: String? {
        currentUser?.providerData.first?.providerID
    }

    // MARK: - Guest Mode
    func continueAsGuest() {
        isGuest = true
    }

    // MARK: - Google Sign-In
    func signInWithGoogle(presenting viewController: UIViewController,
                          completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(AuthError.missingClientID))
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(AuthError.missingToken))
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    DispatchQueue.main.async { completion(.failure(error)) }
                } else if let firebaseUser = authResult?.user {
                    self.isGuest = false
                    DispatchQueue.main.async { completion(.success(firebaseUser)) }
                }
            }
        }
    }
    // MARK: - Sign Out
    func signOut() throws {
        if isAuthenticated {
            try Auth.auth().signOut()
        }
        isGuest = false
    }

}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case missingClientID
    case missingToken

    var errorDescription: String? {
        S.authErrorGeneral
    }
}
