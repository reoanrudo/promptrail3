//
//  ContentView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager: AuthManager
    @StateObject private var firestoreManager: FirestoreManager
    @StateObject private var store: PromptStore

    init() {
        let authManager = AuthManager()
        let firestoreManager = FirestoreManager()
        _authManager = StateObject(wrappedValue: authManager)
        _firestoreManager = StateObject(wrappedValue: firestoreManager)
        _store = StateObject(wrappedValue: PromptStore(authManager: authManager, firestoreManager: firestoreManager))
    }

    var body: some View {
        Group {
            if authManager.isLoading {
                // 認証状態を確認中
                ProgressView("読み込み中...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if authManager.isAuthenticated {
                // ログイン済み - メインアプリを表示
                CustomTabBarView()
                    .environmentObject(store)
                    .environmentObject(authManager)
                    .environmentObject(firestoreManager)
                    .onAppear {
                        Task {
                            await withTaskGroup(of: Void.self) { group in
                                group.addTask {
                                    try? await store.loadUserTemplatesFromFirebase()
                                }
                                group.addTask {
                                    try? await store.loadCommunityQuickPrompts()
                                }
                                group.addTask {
                                    try? await store.loadCommunityImagePrompts()
                                }
                            }
                        }
                    }
            } else {
                // 未ログイン - ウェルカム画面を表示
                WelcomeView()
                    .environmentObject(authManager)
            }
        }
    }
}

#Preview {
    ContentView()
}
