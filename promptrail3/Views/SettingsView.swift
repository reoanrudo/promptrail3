//
//  SettingsView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showAbout = false
    @State private var showLogoutConfirm = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            List {
                // プロフィールセクション
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(authManager.isAnonymous ? "ゲストユーザー" : "ユーザー")
                                .font(.headline)
                            if authManager.isAnonymous {
                                Text("ログインして同期を有効化")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else if let userId = authManager.userId {
                                Text("ID: \(userId.prefix(8))...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("プロフィール")
                }

                // アカウントセクション
                Section {
                    if authManager.isAnonymous {
                        NavigationLink {
                            ComingSoonView(feature: "アカウント連携")
                        } label: {
                            Label("アカウント連携", systemImage: "person.badge.plus")
                        }
                    }

                    NavigationLink {
                        ComingSoonView(feature: "データ同期")
                    } label: {
                        Label("データ同期", systemImage: "arrow.triangle.2.circlepath")
                    }

                    // ログアウトボタン
                    Button(role: .destructive) {
                        showLogoutConfirm = true
                    } label: {
                        Label("ログアウト", systemImage: "arrow.right.square")
                    }
                } header: {
                    Text("アカウント")
                } footer: {
                    if authManager.isAnonymous {
                        Text("ログアウトすると、ゲストユーザーとして保存したデータにアクセスできなくなります。")
                    }
                }

                // 表示設定セクション
                Section {
                    Toggle(isOn: $isDarkMode) {
                        Label("ダークモード", systemImage: "moon.fill")
                    }
                } header: {
                    Text("表示設定")
                }

                // データ管理セクション
                Section {
                    NavigationLink {
                        DataManagementView()
                    } label: {
                        Label("データ管理", systemImage: "externaldrive")
                    }
                } header: {
                    Text("データ")
                }

                // アプリ情報セクション
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("PromptRailについて", systemImage: "info.circle")
                    }

                    Link(destination: URL(string: "https://example.com/terms")!) {
                        Label("利用規約", systemImage: "doc.text")
                    }

                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label("プライバシーポリシー", systemImage: "hand.raised")
                    }

                    NavigationLink {
                        LicenseView()
                    } label: {
                        Label("ライセンス", systemImage: "scroll")
                    }
                } header: {
                    Text("アプリ情報")
                }

                // バージョン情報
                Section {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("設定")
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .alert("ログアウトしますか？", isPresented: $showLogoutConfirm) {
            Button("ログアウト", role: .destructive) {
                logout()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            if authManager.isAnonymous {
                Text("ゲストユーザーとして保存したデータにアクセスできなくなります。")
            } else {
                Text("再度ログインすることで、データにアクセスできます。")
            }
        }
        .alert("エラー", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func logout() {
        do {
            try authManager.signOut()
            print("✅ ログアウト成功")
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ ログアウト失敗: \(error.localizedDescription)")
        }
    }
}

// MARK: - Coming Soon View
struct ComingSoonView: View {
    let feature: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("開発中")
                .font(.title2)
                .fontWeight(.bold)

            Text("\(feature)は今後のアップデートで追加予定です")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle(feature)
    }
}

// MARK: - Data Management View
struct DataManagementView: View {
    @EnvironmentObject var store: PromptStore
    @State private var showClearConfirm = false

    var body: some View {
        List {
            Section {
                HStack {
                    Text("お気に入り")
                    Spacer()
                    Text("\(store.favorites.count)件")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("使用履歴")
                    Spacer()
                    Text("\(store.usageHistory.count)件")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("フォルダ")
                    Spacer()
                    Text("\(store.folders.count)件")
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("保存データ")
            }

            Section {
                Button(role: .destructive) {
                    showClearConfirm = true
                } label: {
                    Label("すべてのデータを削除", systemImage: "trash")
                }
            } footer: {
                Text("お気に入り、使用履歴、フォルダがすべて削除されます。この操作は取り消せません。")
            }
        }
        .navigationTitle("データ管理")
        .alert("データを削除しますか？", isPresented: $showClearConfirm) {
            Button("削除", role: .destructive) {
                // TODO: データ削除処理
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("すべてのお気に入り、使用履歴、フォルダが削除されます。")
        }
    }
}

// MARK: - About View
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // アプリアイコン
                Image(systemName: "tram.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .padding(.top, 40)

                // アプリ名
                VStack(spacing: 8) {
                    Text("PromptRail")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("プロンプトカタログ＆共有アプリ")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // タグライン
                Text("見つける、カスタムする、使いこなす。\nプロンプトの定番を、あなたの手元に。")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // 説明
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(
                        icon: "magnifyingglass",
                        title: "発見",
                        description: "カテゴリやタスクから最適なプロンプトを見つける"
                    )

                    FeatureRow(
                        icon: "slider.horizontal.3",
                        title: "カスタマイズ",
                        description: "変数を入力するだけで自分用にカスタマイズ"
                    )

                    FeatureRow(
                        icon: "bookmark.fill",
                        title: "定番化",
                        description: "お気に入りに保存して繰り返し使用"
                    )
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer()
            }
        }
        .navigationTitle("PromptRailについて")
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - License View
struct LicenseView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("オープンソースライセンス")
                    .font(.headline)

                Text("このアプリは以下のオープンソースソフトウェアを使用しています。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // ライセンス一覧（今後追加）
                Text("現在、外部ライブラリは使用していません。")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle("ライセンス")
    }
}

#Preview {
    SettingsView()
        .environmentObject(PromptStore())
        .environmentObject(AuthManager())
}
