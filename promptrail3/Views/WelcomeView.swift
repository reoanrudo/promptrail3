//
//  WelcomeView.swift
//  promptrail3
//
//  初回起動時の認証画面
//

import SwiftUI
import AuthenticationServices

struct WelcomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isAppleLoading = false
    @State private var isGoogleLoading = false
    @State private var isAnonymousLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showComingSoon = false
    @State private var comingSoonFeature = ""
    @State private var showEmailAuth = false

    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                gradient: Gradient(colors: [.prCategoryBlue.opacity(0.1), .prBackground]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: PRSpacing.xl) {
                Spacer()

                // ロゴ・アイコン
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.prCategoryBlue)
                    .padding(.bottom, PRSpacing.md)

                // アプリ名
                Text("manebu")
                    .font(PRTypography.displayLarge)
                    .foregroundColor(.prGray100)

                // キャッチコピー
                Text("真似て学ぶ、プロンプトの力")
                    .font(PRTypography.bodyLarge)
                    .foregroundColor(.prGray60)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, PRSpacing.xl)

                Spacer()

                // 機能紹介
                VStack(spacing: PRSpacing.md) {
                    WelcomeFeatureRow(
                        icon: "square.stack.3d.up.fill",
                        title: "豊富なテンプレート",
                        description: "様々なシーンで使えるプロンプトを発見"
                    )

                    WelcomeFeatureRow(
                        icon: "arrow.triangle.branch",
                        title: "カスタマイズ",
                        description: "テンプレートを自分好みに編集"
                    )

                    WelcomeFeatureRow(
                        icon: "person.3.fill",
                        title: "コミュニティ",
                        description: "他のユーザーのテンプレートを学ぶ"
                    )
                }
                .padding(.horizontal, PRSpacing.xl)

                Spacer()

                // ログインボタン
                VStack(spacing: PRSpacing.md) {
                    // Apple認証ボタン
                    SignInWithAppleButton(
                        onRequest: { request in
                            let nonce = authManager.randomNonceString()
                            authManager.currentNonce = nonce
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = authManager.sha256(nonce)
                        },
                        onCompletion: { result in
                            handleAppleSignInCompletion(result)
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .disabled(isGoogleLoading || isAppleLoading || isAnonymousLoading)

                    // Google認証ボタン
                    Button(action: signInWithGoogle) {
                        HStack {
                            if isGoogleLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "g.circle.fill")
                                Text("Googleでログイン")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PRPrimaryButtonStyle())
                    .disabled(isGoogleLoading || isAppleLoading || isAnonymousLoading)

                    // メールアドレス認証ボタン
                    Button(action: { showEmailAuth = true }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("メールアドレスでログイン")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PRSecondaryButtonStyle())

                    // 区切り線
                    HStack {
                        Rectangle()
                            .fill(Color.prGray20)
                            .frame(height: 1)
                        Text("または")
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray40)
                            .padding(.horizontal, PRSpacing.sm)
                        Rectangle()
                            .fill(Color.prGray20)
                            .frame(height: 1)
                    }
                    .padding(.vertical, PRSpacing.xs)

                    // 匿名ログインボタン
                    Button(action: signInAnonymously) {
                        HStack {
                            if isAnonymousLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "play.fill")
                                Text("アカウントなしで始める")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PRSecondaryButtonStyle())
                    .disabled(isAnonymousLoading || isGoogleLoading || isAppleLoading)

                    Text("アカウント作成不要で今すぐ利用できます")
                        .font(PRTypography.labelSmall)
                        .foregroundColor(.prGray40)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, PRSpacing.xl)
                .padding(.bottom, PRSpacing.xl)
            }
        }
        .alert("エラー", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("開発中", isPresented: $showComingSoon) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\(comingSoonFeature)は今後のアップデートで追加予定です")
        }
        .sheet(isPresented: $showEmailAuth) {
            EmailAuthView()
                .environmentObject(authManager)
        }
    }

    private func handleAppleSignInCompletion(_ result: Result<ASAuthorization, Error>) {
        isAppleLoading = true

        Task {
            do {
                switch result {
                case .success(let authorization):
                    try await authManager.handleSignInWithAppleCompletion(authorization)
                    print("✅ Apple Sign-In successful")
                case .failure(let error):
                    throw error
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                print("❌ Apple Sign-In failed: \(error.localizedDescription)")
            }
            isAppleLoading = false
        }
    }

    private func signInWithGoogle() {
        print("🔵 Google Sign-In button tapped")
        isGoogleLoading = true

        Task {
            do {
                try await authManager.signInWithGoogle()
                print("✅ Google Sign-In successful")
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                print("❌ Google Sign-In failed: \(error.localizedDescription)")
            }
            isGoogleLoading = false
        }
    }

    private func signInAnonymously() {
        print("🔵 Sign in button tapped")
        isAnonymousLoading = true

        Task {
            do {
                print("🔵 Starting anonymous sign in...")
                try await authManager.signInAnonymously()
                print("✅ Sign in successful")
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                print("❌ Sign in failed: \(error.localizedDescription)")
                print("❌ Error details: \(error)")
            }
            isAnonymousLoading = false
            print("🔵 Sign in process completed, isAnonymousLoading: \(isAnonymousLoading)")
        }
    }
}

// MARK: - Welcome Feature Row
private struct WelcomeFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: PRSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.prCategoryBlue)
                .frame(width: 50)

            VStack(alignment: .leading, spacing: PRSpacing.xs) {
                Text(title)
                    .font(PRTypography.headlineSmall)
                    .foregroundColor(.prGray100)

                Text(description)
                    .font(PRTypography.bodySmall)
                    .foregroundColor(.prGray60)
            }

            Spacer()
        }
    }
}

// MARK: - Email Auth View
struct EmailAuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PRSpacing.xl) {
                    // タイトル
                    VStack(spacing: PRSpacing.sm) {
                        Text(isSignUp ? "新規登録" : "ログイン")
                            .font(PRTypography.displayMedium)
                            .foregroundColor(.prGray100)

                        Text(isSignUp ? "メールアドレスでアカウント作成" : "メールアドレスでログイン")
                            .font(PRTypography.bodyMedium)
                            .foregroundColor(.prGray60)
                    }
                    .padding(.top, PRSpacing.xl)

                    // フォーム
                    VStack(spacing: PRSpacing.md) {
                        // メールアドレス
                        VStack(alignment: .leading, spacing: PRSpacing.xs) {
                            Text("メールアドレス")
                                .font(PRTypography.labelMedium)
                                .foregroundColor(.prGray80)

                            TextField("example@email.com", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color.prGray10)
                                .cornerRadius(PRRadius.md)
                        }

                        // パスワード
                        VStack(alignment: .leading, spacing: PRSpacing.xs) {
                            Text("パスワード")
                                .font(PRTypography.labelMedium)
                                .foregroundColor(.prGray80)

                            SecureField("パスワード（6文字以上）", text: $password)
                                .textContentType(isSignUp ? .newPassword : .password)
                                .padding()
                                .background(Color.prGray10)
                                .cornerRadius(PRRadius.md)
                        }
                    }
                    .padding(.horizontal, PRSpacing.xl)

                    // ログイン/登録ボタン
                    Button(action: handleAuth) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(isSignUp ? "登録" : "ログイン")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PRPrimaryButtonStyle())
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    .padding(.horizontal, PRSpacing.xl)

                    // 切り替えボタン
                    Button(action: { isSignUp.toggle() }) {
                        Text(isSignUp ? "アカウントをお持ちの方はログイン" : "アカウントをお持ちでない方は新規登録")
                            .font(PRTypography.labelMedium)
                            .foregroundColor(.prCategoryBlue)
                    }

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
        .alert("エラー", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func handleAuth() {
        isLoading = true

        Task {
            do {
                if isSignUp {
                    try await authManager.signUpWithEmail(email: email, password: password)
                    print("✅ Sign up successful")
                } else {
                    try await authManager.signInWithEmail(email: email, password: password)
                    print("✅ Sign in successful")
                }
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                print("❌ Auth failed: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthManager())
}
