//
//  SearchOverlayView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI

struct SearchOverlayView: View {
    @EnvironmentObject var store: PromptStore
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @State private var selectedTask: PromptTask?
    @State private var selectedPrompt: Prompt?
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 検索バー
                HStack(spacing: PRSpacing.sm) {
                    // 閉じるボタン
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.prGray60)
                    }

                    // 検索フィールド
                    HStack(spacing: PRSpacing.xs) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16))
                            .foregroundColor(.prGray40)

                        TextField("プロンプトを検索...", text: $searchText)
                            .font(PRTypography.bodyMedium)
                            .focused($isSearchFocused)

                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.prGray40)
                            }
                        }
                    }
                    .padding(PRSpacing.sm)
                    .background(Color.prGray5)
                    .cornerRadius(PRRadius.md)
                }
                .padding(PRSpacing.md)

                // フィルターチップ
                if !searchText.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: PRSpacing.xs) {
                            // カテゴリフィルター
                            FilterChipButton(
                                title: selectedCategory?.name ?? "カテゴリ",
                                isSelected: selectedCategory != nil,
                                onTap: {
                                    // TODO: カテゴリ選択シート
                                },
                                onClear: { selectedCategory = nil }
                            )

                            // タスクフィルター
                            FilterChipButton(
                                title: selectedTask?.name ?? "タスク",
                                isSelected: selectedTask != nil,
                                onTap: {
                                    // TODO: タスク選択シート
                                },
                                onClear: { selectedTask = nil }
                            )
                        }
                        .padding(.horizontal, PRSpacing.md)
                        .padding(.bottom, PRSpacing.sm)
                    }
                }

                Divider()

                // コンテンツ
                if searchText.isEmpty {
                    // 検索前：履歴とサジェスト
                    SearchSuggestionsView()
                } else {
                    // 検索結果
                    SearchResultsView(
                        results: searchResults,
                        searchText: searchText,
                        selectedPrompt: $selectedPrompt
                    )
                }
            }
            .background(Color.white)
            .navigationDestination(item: $selectedPrompt) { prompt in
                PromptDetailView(prompt: prompt)
            }
        }
        .onAppear {
            isSearchFocused = true
        }
    }

    // MARK: - Search Results
    private var searchResults: [Prompt] {
        var results = store.searchPrompts(query: searchText)

        if let category = selectedCategory {
            results = results.filter { $0.categoryId == category.id }
        }
        if let task = selectedTask {
            results = results.filter { $0.taskId == task.id }
        }

        return results
    }
}

// MARK: - Filter Chip Button
struct FilterChipButton: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    let onClear: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: PRSpacing.xxs) {
                Text(title)
                    .font(PRTypography.labelMedium)

                if isSelected {
                    Button(action: onClear) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                    }
                } else {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                }
            }
            .padding(.horizontal, PRSpacing.sm)
            .padding(.vertical, PRSpacing.xs)
            .background(isSelected ? Color.prOrange : Color.prGray5)
            .foregroundColor(isSelected ? .white : .prGray80)
            .cornerRadius(PRRadius.pill)
        }
    }
}

// MARK: - Search Suggestions View
struct SearchSuggestionsView: View {
    @EnvironmentObject var store: PromptStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PRSpacing.lg) {
                // トレンドキーワード
                VStack(alignment: .leading, spacing: PRSpacing.sm) {
                    Text("人気のキーワード")
                        .font(PRTypography.headlineSmall)
                        .foregroundColor(.prGray100)

                    FlowLayout(spacing: PRSpacing.xs) {
                        ForEach(trendKeywords, id: \.self) { keyword in
                            Text(keyword)
                                .font(PRTypography.labelMedium)
                                .foregroundColor(.prGray80)
                                .padding(.horizontal, PRSpacing.sm)
                                .padding(.vertical, PRSpacing.xs)
                                .background(Color.prGray5)
                                .cornerRadius(PRRadius.pill)
                        }
                    }
                }

                // カテゴリから探す
                VStack(alignment: .leading, spacing: PRSpacing.sm) {
                    Text("カテゴリから探す")
                        .font(PRTypography.headlineSmall)
                        .foregroundColor(.prGray100)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: PRSpacing.sm) {
                        ForEach(store.categories.prefix(6)) { category in
                            CategoryGridItem(category: category)
                        }
                    }
                }
            }
            .padding(PRSpacing.md)
        }
    }

    private var trendKeywords: [String] {
        ["ブログ", "メール", "要約", "翻訳", "アイデア", "分析"]
    }
}

// MARK: - Category Grid Item
struct CategoryGridItem: View {
    let category: Category

    var body: some View {
        VStack(spacing: PRSpacing.xs) {
            Image(systemName: category.icon)
                .font(.system(size: 24))
                .foregroundColor(.prOrange)

            Text(category.name)
                .font(PRTypography.labelMedium)
                .foregroundColor(.prGray80)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PRSpacing.md)
        .background(Color.prGray5)
        .cornerRadius(PRRadius.md)
    }
}

// MARK: - Search Results View
struct SearchResultsView: View {
    let results: [Prompt]
    let searchText: String
    @Binding var selectedPrompt: Prompt?

    var body: some View {
        if results.isEmpty {
            // 結果なし
            VStack(spacing: PRSpacing.md) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 48))
                    .foregroundColor(.prGray40)

                Text("「\(searchText)」の検索結果がありません")
                    .font(PRTypography.bodyMedium)
                    .foregroundColor(.prGray60)

                Text("別のキーワードで検索してください")
                    .font(PRTypography.labelSmall)
                    .foregroundColor(.prGray40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: PRSpacing.sm) {
                    Text("「\(searchText)」の検索結果 \(results.count)件")
                        .font(PRTypography.labelSmall)
                        .foregroundColor(.prGray60)
                        .padding(.horizontal, PRSpacing.md)
                        .padding(.top, PRSpacing.sm)

                    LazyVStack(spacing: PRSpacing.sm) {
                        ForEach(results) { prompt in
                            Button(action: { selectedPrompt = prompt }) {
                                PromptCard(prompt: prompt)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, PRSpacing.md)
                    .padding(.bottom, PRSpacing.md)
                }
            }
        }
    }
}


#Preview {
    SearchOverlayView()
        .environmentObject(PromptStore())
}
