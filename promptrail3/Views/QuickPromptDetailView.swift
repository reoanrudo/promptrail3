//
//  QuickPromptDetailView.swift
//  promptrail3
//
//  クイックプロンプトの詳細ページ（収益化対策版）
//  作者情報、説明、出力例、推奨モデルなどを表示してから使用ページへ
//

import SwiftUI

struct QuickPromptDetailView: View {
    let prompt: QuickPrompt
    @EnvironmentObject var store: PromptStore
    @Environment(\.dismiss) private var dismiss
    @State private var showCopyView = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PRSpacing.lg) {
                // ヘッダー - カテゴリバッジとタイトル
                VStack(alignment: .leading, spacing: PRSpacing.sm) {
                    HStack {
                        Text(prompt.category.rawValue)
                            .font(PRTypography.labelSmall)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(prompt.category.color)
                            .cornerRadius(PRRadius.sm)

                        Spacer()

                        // いいねアイコン
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.prCoral)
                            Text("\(prompt.likeCount)")
                                .font(PRTypography.labelSmall)
                                .foregroundColor(Color.prTextSecondary)
                        }
                    }

                    Text(prompt.title)
                        .font(PRTypography.headlineLarge)
                        .fontWeight(.bold)
                        .foregroundColor(.prGray100)
                }
                .padding(.horizontal, PRSpacing.md)

                // 作者情報カード
                VStack(alignment: .leading, spacing: PRSpacing.sm) {
                    HStack(spacing: 12) {
                        // 作者アイコン
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.prOrange, .prCategoryBlue]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 50, height: 50)

                            Image(systemName: "person.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(prompt.userId ?? "システム公式")
                                .font(PRTypography.bodyMedium)
                                .fontWeight(.semibold)
                                .foregroundColor(.prGray100)

                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.prCategoryBlue)
                                    Text("\(prompt.useCount)回使用")
                                        .font(PRTypography.labelSmall)
                                        .foregroundColor(.prGray60)
                                }

                                HStack(spacing: 4) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.prGray40)
                                    Text(formatDate(prompt.createdAt))
                                        .font(PRTypography.labelSmall)
                                        .foregroundColor(.prGray60)
                                }
                            }
                        }

                        Spacer()
                    }
                }
                .padding(PRSpacing.md)
                .background(Color.prCardBackground)
                .cornerRadius(PRRadius.md)
                .padding(.horizontal, PRSpacing.md)

                Divider()
                    .padding(.horizontal, PRSpacing.md)

                // プロンプトの説明
                VStack(alignment: .leading, spacing: PRSpacing.sm) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.prOrange)
                        Text("プロンプトについて")
                            .font(PRTypography.headlineSmall)
                            .fontWeight(.semibold)
                            .foregroundColor(.prGray100)
                    }

                    Text(prompt.description)
                        .font(PRTypography.bodyMedium)
                        .foregroundColor(.prGray80)
                        .lineSpacing(6)
                }
                .padding(.horizontal, PRSpacing.md)

                // 詳細説明4項目
                VStack(alignment: .leading, spacing: PRSpacing.md) {
                    // 用途
                    DetailSection(
                        icon: "target",
                        iconColor: .prCategoryBlue,
                        title: "用途",
                        content: prompt.usageDescription.isEmpty ? "このプロンプトの具体的な使用場面" : prompt.usageDescription
                    )

                    // 前提
                    DetailSection(
                        icon: "info.circle.fill",
                        iconColor: .prOrange,
                        title: "前提",
                        content: prompt.prerequisites.isEmpty ? "使用する際に必要な前提条件や準備" : prompt.prerequisites
                    )

                    // 期待出力
                    DetailSection(
                        icon: "checkmark.circle.fill",
                        iconColor: .green,
                        title: "期待出力",
                        content: prompt.expectedOutput.isEmpty ? "このプロンプトで得られる結果の例" : prompt.expectedOutput
                    )

                    // NG例
                    DetailSection(
                        icon: "xmark.circle.fill",
                        iconColor: .red,
                        title: "NG例",
                        content: prompt.ngExamples.isEmpty ? "避けるべき使い方や注意点" : prompt.ngExamples
                    )
                }
                .padding(.horizontal, PRSpacing.md)

                // アクションボタン群
                VStack(spacing: PRSpacing.sm) {
                    // このプロンプトを使うボタン
                    Button(action: {
                        showCopyView = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 18))
                            Text("このプロンプトを使う")
                                .font(PRTypography.bodyMedium)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.prOrange, .prCoral]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(PRRadius.md)
                        .shadow(color: .prOrange.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, PRSpacing.md)
                .padding(.bottom, 32)
            }
            .padding(.top, PRSpacing.md)
        }
        .background(Color.prBackground)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCopyView) {
            QuickPromptCopyView(prompt: prompt)
                .environmentObject(store)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: 100)
        }
    }

    // 日付フォーマット
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - QuickPromptCopyView
struct QuickPromptCopyView: View {
    let prompt: QuickPrompt
    @EnvironmentObject var store: PromptStore
    @Environment(\.dismiss) private var dismiss
    @State private var showCopiedToast = false
    @State private var showSavedToast = false
    @State private var variableValues: [String: String] = [:]

    // プロンプトから変数を抽出
    private var variables: [String] {
        let pattern = "\\{([^}]+)\\}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let nsString = prompt.promptText as NSString
        let matches = regex.matches(in: prompt.promptText, range: NSRange(location: 0, length: nsString.length))

        var vars: [String] = []
        for match in matches {
            if match.numberOfRanges > 1 {
                let range = match.range(at: 1)
                let variable = nsString.substring(with: range)
                if !vars.contains(variable) {
                    vars.append(variable)
                }
            }
        }
        return vars
    }

    // 変数を埋めたプロンプト
    private var filledPrompt: String {
        var result = prompt.promptText
        for (key, value) in variableValues {
            result = result.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return result
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PRSpacing.lg) {
                    // 変数入力フォーム
                    if !variables.isEmpty {
                        VStack(alignment: .leading, spacing: PRSpacing.md) {
                            HStack(spacing: PRSpacing.xs) {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.prOrange)
                                Text("変数を入力")
                                    .font(PRTypography.headlineSmall)
                                    .foregroundColor(.prGray100)
                            }

                            VStack(spacing: PRSpacing.sm) {
                                ForEach(variables, id: \.self) { variable in
                                    VStack(alignment: .leading, spacing: PRSpacing.xxs) {
                                        Text(variable)
                                            .font(PRTypography.labelMedium)
                                            .foregroundColor(.prGray60)

                                        TextField("入力してください", text: Binding(
                                            get: { variableValues[variable] ?? "" },
                                            set: { variableValues[variable] = $0 }
                                        ))
                                        .font(PRTypography.bodyMedium)
                                        .padding(PRSpacing.sm)
                                        .background(Color.white)
                                        .cornerRadius(PRRadius.sm)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: PRRadius.sm)
                                                .stroke(Color.prGray20, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        .padding(PRSpacing.md)
                        .background(Color.prOrange.opacity(0.05))
                        .cornerRadius(PRRadius.md)
                        .padding(.horizontal, PRSpacing.md)
                    }

                    // プロンプト全文表示
                    VStack(alignment: .leading, spacing: PRSpacing.sm) {
                        Text("プロンプト")
                            .font(PRTypography.headlineSmall)
                            .foregroundColor(.prGray100)

                        Text(filledPrompt)
                            .font(PRTypography.code)
                            .foregroundColor(.prGray80)
                            .textSelection(.enabled)
                            .padding(PRSpacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.prGray5)
                            .cornerRadius(PRRadius.md)

                        HStack(spacing: PRSpacing.sm) {
                            Button(action: saveToMyPrompts) {
                                HStack {
                                    Image(systemName: showSavedToast ? "bookmark.fill" : "bookmark")
                                    Text(showSavedToast ? "保存済み" : "マイページに保存")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PRSecondaryButtonStyle())

                            Button(action: {
                                store.toggleQuickPromptLike(prompt.id)
                            }) {
                                HStack {
                                    Image(systemName: store.isQuickPromptLiked(prompt.id) ? "heart.fill" : "heart")
                                        .font(.system(size: 16))
                                    Text(store.isQuickPromptLiked(prompt.id) ? "いいね済み" : "いいね")
                                        .font(PRTypography.labelMedium)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.vertical, 2)
                            .buttonStyle(.borderedProminent)
                            .tint(store.isQuickPromptLiked(prompt.id) ? .prCoral : .prGray20)
                            .foregroundColor(store.isQuickPromptLiked(prompt.id) ? .white : .prGray80)
                        }
                    }
                    .padding(.horizontal, PRSpacing.md)

                    // アクションボタン
                    VStack(spacing: PRSpacing.sm) {
                        // コピーボタン
                        Button(action: copyToClipboard) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("コピー")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PRPrimaryButtonStyle())
                    }
                    .padding(.horizontal, PRSpacing.md)
                }
                .padding(.top, PRSpacing.md)
                .padding(.bottom, PRSpacing.xl)
            }
            .navigationTitle(prompt.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
        .alert("コピーしました", isPresented: $showCopiedToast) {
            Button("OK", role: .cancel) {}
        }
        .alert("保存しました", isPresented: $showSavedToast) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("マイページから確認できます")
        }
    }

    private func copyToClipboard() {
        UIPasteboard.general.string = filledPrompt
        store.recordQuickPromptUsage(prompt.id)
        showCopiedToast = true
    }

    private func saveToMyPrompts() {
        store.saveQuickPrompt(prompt)
        showSavedToast = true
    }
}

// MARK: - 推奨モデル行コンポーネント
struct RecommendedModelRow: View {
    let modelName: String
    let provider: String
    let badge: String
    let badgeColor: Color

    var body: some View {
        HStack {
            HStack(spacing: 10) {
                // モデルアイコン
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(badgeColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 18))
                        .foregroundColor(badgeColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(modelName)
                        .font(PRTypography.bodyMedium)
                        .fontWeight(.medium)
                        .foregroundColor(.prGray100)
                    Text(provider)
                        .font(PRTypography.labelSmall)
                        .foregroundColor(.prGray60)
                }
            }

            Spacer()

            Text(badge)
                .font(PRTypography.labelSmall)
                .fontWeight(.semibold)
                .foregroundColor(badgeColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(badgeColor.opacity(0.15))
                .cornerRadius(PRRadius.sm)
        }
        .padding(PRSpacing.sm)
        .background(Color.white)
        .cornerRadius(PRRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: PRRadius.md)
                .stroke(Color.prGray20, lineWidth: 1)
        )
    }
}

// MARK: - プロンプトコピー用のビュー
//struct QuickPromptCopyView: View {
//    @EnvironmentObject var store: PromptStore
//    let prompt: QuickPrompt
//    @Environment(\.dismiss) var dismiss
//    @State private var copied = false
//    @State private var variableValues: [String: String] = [:]
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: PRSpacing.lg) {
//                // ヘッダー
//                VStack(spacing: PRSpacing.sm) {
//                    Text(prompt.title)
//                        .font(PRTypography.headlineMedium)
//                        .fontWeight(.bold)
//                        .foregroundColor(.prGray100)
//                        .multilineTextAlignment(.center)
//                        .padding(.top, PRSpacing.md)
//
//                    Text("コピーしてAIチャットに貼り付けて使用できます")
//                        .font(PRTypography.labelMedium)
//                        .foregroundColor(.prGray60)
//                        .multilineTextAlignment(.center)
//                }
//                .padding(.horizontal, PRSpacing.md)
//
//                // プロンプト表示エリア
//                ScrollView {
//                    Text(filledPrompt)
//                        .font(PRTypography.code)
//                        .foregroundColor(.prGray80)
//                        .padding(PRSpacing.md)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .background(Color.prSurfaceElevated)
//                        .cornerRadius(PRRadius.md)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: PRRadius.md)
//                                .stroke(Color.prGray20, lineWidth: 1)
//                        )
//                        .textSelection(.enabled)
//                }
//                .padding(.horizontal, PRSpacing.md)
//
//                // コピーボタン
//                Button(action: {
//                    UIPasteboard.general.string = filledPrompt
//                    copied = true
//
//                    // 使用回数をカウント
//                    if let index = store.quickPrompts.firstIndex(where: { $0.id == prompt.id }) {
//                        store.quickPrompts[index].useCount += 1
//                    }
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
//                        dismiss()
//                    }
//                }) {
//                    HStack(spacing: 8) {
//                        Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc")
//                            .font(.system(size: 18))
//                        Text(copied ? "コピーしました！" : "プロンプトをコピー")
//                            .font(PRTypography.bodyMedium)
//                            .fontWeight(.semibold)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 16)
//                    .background(copied ? Color.green : Color.prOrange)
//                    .foregroundColor(.white)
//                    .cornerRadius(PRRadius.md)
//                    .shadow(color: (copied ? Color.green : Color.prOrange).opacity(0.3), radius: 8, x: 0, y: 4)
//                }
//                .padding(.horizontal, PRSpacing.md)
//                .padding(.bottom, PRSpacing.md)
//                .disabled(copied)
//            }
//            .background(Color.prBackground)
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("閉じる") {
//                        dismiss()
//                    }
//                    .foregroundColor(.prGray80)
//                }
//            }
//        }
//    }
//
//    private var variables: [String] {
//        let pattern = "\\{([^}]+)\\}"
//        let regex = try? NSRegularExpression(pattern: pattern)
//        let nsString = prompt.promptText as NSString
//        let results = regex?.matches(in: prompt.promptText, range: NSRange(location: 0, length: nsString.length))
//
//        var vars: [String] = []
//        results?.forEach { result in
//            if result.numberOfRanges > 1 {
//                let range = result.range(at: 1)
//                let variable = nsString.substring(with: range)
//                if !vars.contains(variable) {
//                    vars.append(variable)
//                }
//            }
//        }
//        return vars
//    }
//
//    private var filledPrompt: String {
//        var text = prompt.promptText
//        for (key, value) in variableValues {
//            text = text.replacingOccurrences(of: "{\(key)}", with: value)
//        }
//        return text
//    }
//}

// MARK: - Detail Section Component
struct DetailSection: View {
    let icon: String
    let iconColor: Color
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: PRSpacing.xs) {
            HStack(spacing: PRSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(PRTypography.labelMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.prGray100)
            }

            Text(content)
                .font(PRTypography.bodyMedium)
                .foregroundColor(.prGray80)
                .lineSpacing(4)
                .padding(PRSpacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.prGray5)
                .cornerRadius(PRRadius.sm)
        }
    }
}

#Preview {
    NavigationView {
        QuickPromptDetailView(prompt: QuickPrompt.defaultPrompts[0])
            .environmentObject(PromptStore())
    }
}
