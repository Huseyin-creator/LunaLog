import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class AuthService {
    static let shared = AuthService()
    private init() {}

    private let defaults = UserDefaults(suiteName: "group.com.seros.LunaLog") ?? UserDefaults.standard
    private let isGuestKey = "isGuestUser"
    private var currentNonce: String?

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

    // MARK: - Apple Sign-In
    func startAppleSignIn() -> (nonce: String, hashedNonce: String) {
        let nonce = randomNonceString()
        currentNonce = nonce
        return (nonce, sha256(nonce))
    }

    func handleAppleSignIn(authorization: ASAuthorization,
                           completion: @escaping (Result<User, Error>) -> Void) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8),
              let nonce = currentNonce else {
            completion(.failure(AuthError.missingToken))
            return
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
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

    // MARK: - Sign Out
    func signOut() throws {
        if isAuthenticated {
            try Auth.auth().signOut()
        }
        isGuest = false
    }

    // MARK: - Nonce Helpers
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { byte in charset[Int(byte) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
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
