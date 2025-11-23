//
//  QuickPromptsView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/20.
//

import SwiftUI

struct QuickPromptsView: View {
    @EnvironmentObject var store: PromptStore
    @State private var searchText = ""
    @State private var selectedCategory: QuickCategory?
    @State private var selectedPrompt: QuickPrompt?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 検索バー
                SearchBar(text: $searchText, placeholder: "プロンプトを検索...")
                    .padding(.horizontal, PRSpacing.md)
                    .padding(.vertical, PRSpacing.sm)

                // カテゴリタブ
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: PRSpacing.sm) {
                        // すべて
                        CategoryTab(
                            title: "すべて",
                            icon: "square.grid.2x2",
                            isSelected: selectedCategory == nil,
                            action: { selectedCategory = nil }
                        )

                        ForEach(QuickCategory.allCases, id: \.self) { category in
                            CategoryTab(
                                title: category.rawValue,
                                icon: category.icon,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal, PRSpacing.md)
                    .padding(.vertical, PRSpacing.sm)
                }

                Divider()

                // プロンプトリスト
                if filteredPrompts.isEmpty {
                    EmptyQuickView(searchText: searchText)
                } else {
                    ScrollView {
                        LazyVStack(spacing: PRSpacing.sm) {
                            ForEach(filteredPrompts) { prompt in
                                Button(action: { selectedPrompt = prompt }) {
                                    QuickPromptCard(prompt: prompt)
                                }
                                .buttonStyle(PRCardButtonStyle())
                            }
                        }
                        .padding(PRSpacing.md)
                        .padding(.bottom, 80)
                    }
                }
            }
            .background(Color.prBackground)
            .navigationTitle("クイック")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedPrompt) { prompt in
                QuickPromptDetailView(prompt: prompt)
            }
        }
    }

    private var filteredPrompts: [QuickPrompt] {
        var prompts = store.quickPrompts

        // カテゴリフィルター
        if let category = selectedCategory {
            prompts = prompts.filter { $0.category == category }
        }

        // 検索フィルター
        if !searchText.isEmpty {
            prompts = prompts.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.promptText.localizedCaseInsensitiveContains(searchText)
            }
        }

        return prompts
    }
}

// MARK: - Category Tab
struct CategoryTab: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: PRSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(PRTypography.labelMedium)
            }
            .padding(.horizontal, PRSpacing.sm)
            .padding(.vertical, PRSpacing.xs)
            .background(isSelected ? Color.prOrange : Color.prCardBackground)
            .foregroundColor(isSelected ? .white : Color.prTextPrimary)
            .cornerRadius(PRRadius.pill)
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack(spacing: PRSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundColor(Color.prTextTertiary)

            TextField(placeholder, text: $text)
                .font(PRTypography.bodySmall)
                .foregroundColor(Color.prTextPrimary)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.prTextTertiary)
                }
            }
        }
        .padding(.horizontal, PRSpacing.sm)
        .padding(.vertical, PRSpacing.xs)
        .background(Color.prCardBackground)
        .cornerRadius(PRRadius.md)
    }
}

// MARK: - Quick Prompt Card
struct QuickPromptCard: View {
    let prompt: QuickPrompt
    var showDefaultBadge: Bool = true
    @EnvironmentObject var store: PromptStore

    var body: some View {
        VStack(alignment: .leading, spacing: PRSpacing.sm) {
            // ヘッダー
            HStack {
                Image(systemName: prompt.category.icon)
                    .font(.system(size: 16))
                    .foregroundColor(prompt.category.color)

                Text(prompt.category.rawValue)
                    .font(PRTypography.labelSmall)
                    .foregroundColor(Color.prTextSecondary)

                Spacer()

                if showDefaultBadge && prompt.isDefault {
                    Text("デフォルト")
                        .font(PRTypography.labelSmall)
                        .foregroundColor(.prOrange)
                        .padding(.horizontal, PRSpacing.xs)
                        .padding(.vertical, 2)
                        .background(Color.prOrange.opacity(0.1))
                        .cornerRadius(PRRadius.xs)
                }
            }

            // タイトル
            Text(prompt.title)
                .font(PRTypography.bodyMedium)
                .foregroundColor(Color.prTextPrimary)
                .lineLimit(2)

            // 説明
            Text(prompt.description)
                .font(PRTypography.bodySmall)
                .foregroundColor(Color.prTextSecondary)
                .lineLimit(2)

            // 統計
            HStack(spacing: PRSpacing.md) {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.prCoral)
                    Text("\(prompt.likeCount)")
                        .font(PRTypography.labelSmall)
                        .foregroundColor(Color.prTextSecondary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.prCategoryBlue)
                    Text("\(prompt.useCount)")
                        .font(PRTypography.labelSmall)
                        .foregroundColor(Color.prTextSecondary)
                }

                Spacer()
            }
        }
        .padding(PRSpacing.md)
        .background(Color.prCardBackground)
        .cornerRadius(PRRadius.md)
    }
}

// MARK: - Empty Quick View
struct EmptyQuickView: View {
    let searchText: String

    var body: some View {
        VStack(spacing: PRSpacing.md) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(Color.prTextTertiary)

            if searchText.isEmpty {
                Text("No prompts")
                    .font(PRTypography.headlineMedium)
                    .foregroundColor(Color.prTextPrimary)
            } else {
                Text("No results for \"\(searchText)\"")
                    .font(PRTypography.bodyMedium)
                    .foregroundColor(Color.prTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(PRSpacing.xxl)
    }
}

#Preview {
    QuickPromptsView()
        .environmentObject(PromptStore())
}
