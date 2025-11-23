//
//  PromptDetailView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI

struct PromptDetailView: View {
    let prompt: Prompt
    @EnvironmentObject var store: PromptStore
    @State private var showVariableInput = false
    @State private var showCopiedAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PRSpacing.lg) {
                // タイトルセクション
                VStack(alignment: .leading, spacing: PRSpacing.sm) {
                    Text(prompt.title)
                        .font(PRTypography.displayMedium)
                        .foregroundColor(.prGray100)

                    // 作成者・日付
                    HStack(spacing: PRSpacing.sm) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.prGray40)
                            Text(prompt.authorName)
                                .font(PRTypography.labelMedium)
                                .foregroundColor(.prGray60)
                        }

                        Text("•")
                            .foregroundColor(.prGray40)

                        Text(formatDate(prompt.createdAt))
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray40)
                    }

                    // バッジ
                    HStack(spacing: PRSpacing.xs) {
                        if let category = store.category(for: prompt.categoryId) {
                            Badge(text: category.name, icon: category.icon, color: .prCategoryBlue)
                        }
                        if let task = store.task(for: prompt.taskId) {
                            Badge(text: task.name, icon: task.icon, color: .prCategoryGreen)
                        }
                    }
                }
                .padding(.horizontal, PRSpacing.md)

                // 統計バー
                HStack(spacing: PRSpacing.xl) {
                    StatItemView(
                        icon: "heart.fill",
                        value: prompt.likeCount,
                        label: "いいね",
                        color: .prCoral
                    )
                    StatItemView(
                        icon: "bookmark.fill",
                        value: prompt.favoriteCount,
                        label: "保存",
                        color: .prOrange
                    )
                    StatItemView(
                        icon: "arrow.up.circle.fill",
                        value: prompt.useCount,
                        label: "使用",
                        color: .prCategoryBlue
                    )
                }
                .padding(PRSpacing.md)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(PRRadius.md)
                .padding(.horizontal, PRSpacing.md)

                // プロンプト本文
                VStack(alignment: .leading, spacing: PRSpacing.sm) {
                    Text("プロンプト")
                        .font(PRTypography.headlineSmall)
                        .foregroundColor(.prGray100)

                    Text(highlightedBody)
                        .font(PRTypography.code)
                        .padding(PRSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.prGray5)
                        .cornerRadius(PRRadius.sm)
                }
                .padding(.horizontal, PRSpacing.md)

                // 変数セクション
                if !prompt.variables.isEmpty {
                    VStack(alignment: .leading, spacing: PRSpacing.sm) {
                        Text("入力する変数")
                            .font(PRTypography.headlineSmall)
                            .foregroundColor(.prGray100)

                        FlowLayout(spacing: PRSpacing.xs) {
                            ForEach(prompt.variables, id: \.self) { variable in
                                Text("{\(variable)}")
                                    .font(PRTypography.labelMedium)
                                    .padding(.horizontal, PRSpacing.sm)
                                    .padding(.vertical, PRSpacing.xs)
                                    .background(Color.prOrange.opacity(0.1))
                                    .foregroundColor(.prOrange)
                                    .cornerRadius(PRRadius.xs)
                            }
                        }
                    }
                    .padding(.horizontal, PRSpacing.md)
                }

                // 説明セクション
                if let description = prompt.description, !description.isEmpty {
                    VStack(alignment: .leading, spacing: PRSpacing.sm) {
                        Text("使い方")
                            .font(PRTypography.headlineSmall)
                            .foregroundColor(.prGray100)

                        Text(description)
                            .font(PRTypography.bodySmall)
                            .foregroundColor(.prGray60)
                            .padding(PRSpacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.prGray5)
                            .cornerRadius(PRRadius.sm)
                    }
                    .padding(.horizontal, PRSpacing.md)
                }

                // アクションボタンバー
                HStack(spacing: PRSpacing.sm) {
                    // 使うボタン
                    Button(action: {
                        if prompt.variables.isEmpty {
                            copyToClipboard(prompt.body)
                            store.recordUsage(promptId: prompt.id)
                            showCopiedAlert = true
                        } else {
                            showVariableInput = true
                        }
                    }) {
                        Text("使う")
                    }
                    .buttonStyle(PRPrimaryButtonStyle())
                    .frame(maxWidth: .infinity)

                    // 保存ボタン
                    Button(action: {
                        store.toggleFavorite(prompt.id)
                    }) {
                        Image(systemName: store.isFavorite(prompt.id) ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 18))
                            .foregroundColor(store.isFavorite(prompt.id) ? .prOrange : .prGray60)
                    }
                    .frame(width: 52, height: 52)
                    .background(Color.prGray5)
                    .cornerRadius(PRRadius.md)

                    // フォークボタン
                    Button(action: {
                        // TODO: フォーク機能
                    }) {
                        Image(systemName: "arrow.triangle.branch")
                            .font(.system(size: 18))
                            .foregroundColor(.prGray60)
                    }
                    .frame(width: 52, height: 52)
                    .background(Color.prGray5)
                    .cornerRadius(PRRadius.md)
                }
                .padding(.horizontal, PRSpacing.md)
            }
            .padding(.vertical, PRSpacing.md)
            .padding(.bottom, 80)
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ShareLink(item: prompt.body) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.prGray60)
                }
            }
        }
        .sheet(isPresented: $showVariableInput) {
            VariableInputView(prompt: prompt)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .alert("コピーしました", isPresented: $showCopiedAlert) {
            Button("OK", role: .cancel) {}
        }
    }

    // MARK: - Helpers
    private var highlightedBody: AttributedString {
        var result = AttributedString(prompt.body)

        let pattern = "\\{([^}]+)\\}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return result
        }

        let nsString = prompt.body as NSString
        let matches = regex.matches(in: prompt.body, range: NSRange(location: 0, length: nsString.length))

        for match in matches.reversed() {
            if let range = Range(match.range, in: result) {
                result[range].foregroundColor = .prOrange
                result[range].font = PRTypography.code.bold()
            }
        }

        return result
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }

    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
}

// MARK: - Stat Item View
struct StatItemView: View {
    let icon: String
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: PRSpacing.xxs) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                Text(formatValue(value))
                    .font(PRTypography.headlineSmall)
                    .foregroundColor(.prGray100)
            }
            Text(label)
                .font(PRTypography.labelSmall)
                .foregroundColor(.prGray60)
        }
    }

    private func formatValue(_ value: Int) -> String {
        if value >= 1000 {
            return String(format: "%.1fk", Double(value) / 1000)
        }
        return "\(value)"
    }
}

#Preview {
    NavigationStack {
        PromptDetailView(
            prompt: Prompt(
                title: "SEO最適化ブログ記事構成ジェネレーター",
                body: "あなたはSEOとコンテンツマーケティングの専門家です。\n\n## 入力情報\n- メインキーワード：{メインキーワード}\n- ターゲット読者：{ターゲット読者}",
                description: "検索上位を狙えるブログ記事の構成を、ペルソナ分析からCTA設計まで一気通貫で作成します。",
                categoryId: UUID(),
                taskId: UUID(),
                authorName: "公式（高度版）",
                likeCount: 523,
                favoriteCount: 412,
                useCount: 1892
            )
        )
    }
    .environmentObject(PromptStore())
}
