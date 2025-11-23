//
//  AuthManager.swift
//  promptrail3
//
//  Firebase Authentication 管理クラス
//

import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import Combine
import AuthenticationServices
import CryptoKit
import UIKit

@MainActor
class AuthManager: ObservableObject {
    // MARK: - Published Properties

    /// 現在ログイン中のユーザー
    @Published var currentUser: User?

    /// 認証状態 (true = ログイン済み)
    @Published var isAuthenticated = false

    /// 初期化中かどうか
    @Published var isLoading = true

    // MARK: - Private Properties

    private var authStateListener: AuthStateDidChangeListenerHandle?

    // Apple Sign-In用のnonce
    var currentNonce: String?

    // MARK: - Computed Properties

    /// 現在のユーザーID (nilの場合もある)
    var userId: String? {
        currentUser?.uid
    }

    /// 匿名ユーザーかどうか
    var isAnonymous: Bool {
        currentUser?.isAnonymous ?? false
    }

    // MARK: - Initialization

    init() {
        setupAuthStateListener()
    }

    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }

    // MARK: - Auth State Listener

    /// 認証状態の変更を監視
    private func setupAuthStateListener() {
        // 現在の認証状態を即座に取得
        let currentAuthUser = Auth.auth().currentUser
        self.currentUser = currentAuthUser
        self.isAuthenticated = currentAuthUser != nil
        self.isLoading = false

        print("🔐 Initial auth state: \(currentAuthUser != nil ? "Logged in" : "Logged out")")
        if let uid = currentAuthUser?.uid {
            print("   User ID: \(uid)")
            print("   Anonymous: \(currentAuthUser?.isAnonymous ?? false)")
        }

        // リスナーを設定して今後の変更を監視
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil

                print("🔐 Auth state changed: \(user != nil ? "Logged in" : "Logged out")")
                if let uid = user?.uid {
                    print("   User ID: \(uid)")
                    print("   Anonymous: \(user?.isAnonymous ?? false)")
                }
            }
        }
    }

    // MARK: - Sign In Methods

    /// 匿名ログイン
    func signInAnonymously() async throws {
        do {
            let result = try await Auth.auth().signInAnonymously()
            currentUser = result.user
            isAuthenticated = true
            print("✅ Anonymous sign in successful: \(result.user.uid)")
        } catch {
            print("❌ Anonymous sign in failed: \(error.localizedDescription)")
            throw error
        }
    }

    /// Apple ログイン
    func signInWithApple() async throws {
        let nonce = randomNonceString()
        currentNonce = nonce

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        // Note: このメソッドは SwiftUI の SignInWithAppleButton から呼び出す必要があります
        throw NSError(
            domain: "AuthManager",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Please use SignInWithAppleButton"]
        )
    }

    /// Apple認証の結果を処理
    func handleSignInWithAppleCompletion(_ authorization: ASAuthorization) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw NSError(
                domain: "AuthManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Unable to get Apple ID credential"]
            )
        }

        guard let nonce = currentNonce else {
            throw NSError(
                domain: "AuthManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid state: nonce is missing"]
            )
        }

        guard let appleIDToken = appleIDCredential.identityToken else {
            throw NSError(
                domain: "AuthManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"]
            )
        }

        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw NSError(
                domain: "AuthManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Unable to serialize token string"]
            )
        }

        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: idTokenString,
            rawNonce: nonce
        )

        do {
            let result = try await Auth.auth().signIn(with: credential)
            currentUser = result.user
            isAuthenticated = true
            print("✅ Apple sign in successful: \(result.user.uid)")
        } catch {
            print("❌ Apple sign in failed: \(error.localizedDescription)")
            throw error
        }
    }

    /// メールアドレスでログイン
    func signInWithEmail(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            currentUser = result.user
            isAuthenticated = true
            print("✅ Email sign in successful: \(result.user.uid)")
        } catch {
            print("❌ Email sign in failed: \(error.localizedDescription)")
            throw error
        }
    }

    /// メールアドレスで新規登録
    func signUpWithEmail(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            currentUser = result.user
            isAuthenticated = true
            print("✅ Email sign up successful: \(result.user.uid)")
        } catch {
            print("❌ Email sign up failed: \(error.localizedDescription)")
            throw error
        }
    }

    /// Google ログイン
    /// Googleサインイン
    @MainActor
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(
                domain: "AuthManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Firebase clientID が見つかりません"]
            )
        }

        guard let presentingViewController = Self.getRootViewController() else {
            throw NSError(
                domain: "AuthManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "ルートビューコントローラの取得に失敗しました"]
            )
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            guard let idToken = result.user.idToken?.tokenString else {
                throw NSError(
                    domain: "AuthManager",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Google IDトークンの取得に失敗しました"]
                )
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )

            let authResult = try await Auth.auth().signIn(with: credential)
            currentUser = authResult.user
            isAuthenticated = true
            print("✅ Google Sign-In successful: \(authResult.user.uid)")
        } catch {
            print("❌ Google Sign-In failed: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Sign Out

    /// ログアウト
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            isAuthenticated = false
            print("✅ Sign out successful")
        } catch {
            print("❌ Sign out failed: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Account Management

    /// 匿名アカウントを永久アカウントにアップグレード
    /// - Note: 将来的に Email/Apple/Google ログインと連携する際に使用
    func linkAnonymousAccount() async throws {
        guard isAnonymous else {
            throw NSError(
                domain: "AuthManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Current user is not anonymous"]
            )
        }

        // TODO: Implement account linking
        throw NSError(
            domain: "AuthManager",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Account linking is not implemented yet"]
        )
    }

    /// アカウント削除
    func deleteAccount() async throws {
        guard let user = currentUser else {
            throw NSError(
                domain: "AuthManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in"]
            )
        }

        do {
            try await user.delete()
            currentUser = nil
            isAuthenticated = false
            print("✅ Account deleted successfully")
        } catch {
            print("❌ Account deletion failed: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Helper Methods

    /// ランダムなnonceを生成
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    /// nonceのSHA256ハッシュを生成
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

// MARK: - Private Helpers
private extension AuthManager {
    static func getRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive })
        else {
            return nil
        }
        return scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
    }
}
