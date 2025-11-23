//
//  ImagePromptListView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI

struct ImagePromptListView: View {
    @EnvironmentObject var store: PromptStore
    @State private var selectedTemplate: ImagePromptTemplate?
    @State private var selectedTag: String?
    @State private var sortType: ImageSortType = .newest

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // タグフィルター
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: PRSpacing.xs) {
                        // すべて
                        TagChip(
                            name: "すべて",
                            isSelected: selectedTag == nil,
                            action: { selectedTag = nil }
                        )

                        ForEach(ImageTag.allCases, id: \.self) { tag in
                            TagChip(
                                name: tag.rawValue,
                                isSelected: selectedTag == tag.rawValue,
                                action: { selectedTag = tag.rawValue }
                            )
                        }
                    }
                    .padding(.horizontal, PRSpacing.md)
                    .padding(.vertical, PRSpacing.sm)
                }

                // 並び替え
                HStack {
                    Spacer()
                    Menu {
                        ForEach(ImageSortType.allCases, id: \.self) { type in
                            Button(action: { sortType = type }) {
                                if sortType == type {
                                    Label(type.rawValue, systemImage: "checkmark")
                                } else {
                                    Text(type.rawValue)
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: PRSpacing.xxs) {
                            Text(sortType.rawValue)
                                .font(PRTypography.labelSmall)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.prGray60)
                    }
                }
                .padding(.horizontal, PRSpacing.md)
                .padding(.bottom, PRSpacing.sm)

                // カードリスト
                LazyVStack(spacing: PRSpacing.md) {
                    ForEach(filteredAndSortedTemplates) { template in
                        ImagePromptCard(template: template)
                            .contentShape(RoundedRectangle(cornerRadius: PRRadius.md))
                            .onTapGesture {
                                selectedTemplate = template
                            }
                    }
                }
                .padding(.horizontal, PRSpacing.md)
                .padding(.bottom, 80)
            }
        }
        .background(Color.prGray5)
        .navigationDestination(item: $selectedTemplate) { template in
            ImagePromptDetailView(template: template)
        }
    }

    private var filteredAndSortedTemplates: [ImagePromptTemplate] {
        var templates = store.imagePromptTemplates

        // タグフィルター
        if let tag = selectedTag {
            templates = templates.filter { $0.tags.contains(tag) }
        }

        // ソート
        switch sortType {
        case .newest:
            templates.sort { $0.createdAt > $1.createdAt }
        case .popular:
            templates.sort { $0.likeCount > $1.likeCount }
        case .liked:
            let likedIds: Set<UUID> = Set(
                store.imagePromptLikes
                    .filter { $0.userId == store.currentUserIdString }
                    .compactMap { UUID(uuidString: $0.templateId) }
            )
            templates = templates.filter { likedIds.contains($0.id) }
        }

        return templates
    }
}

// MARK: - Image Sort Type
enum ImageSortType: String, CaseIterable {
    case newest = "新着"
    case popular = "人気"
    case liked = "自分のいいね"
}

// MARK: - Tag Chip
struct TagChip: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(PRTypography.labelSmall)
                .padding(.horizontal, PRSpacing.sm)
                .padding(.vertical, PRSpacing.xs)
                .background(isSelected ? Color.prOrange : Color.white)
                .foregroundColor(isSelected ? .white : .prGray80)
                .cornerRadius(PRRadius.pill)
        }
    }
}

// MARK: - Image Prompt Card
struct ImagePromptCard: View {
    let template: ImagePromptTemplate
    @EnvironmentObject var store: PromptStore

    var body: some View {
        HStack(alignment: .top, spacing: PRSpacing.md) {
            // 左側：テキスト情報
            VStack(alignment: .leading, spacing: PRSpacing.xs) {
                // 投稿者
                HStack(spacing: PRSpacing.xxs) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 12))
                        .foregroundColor(.prGray40)
                    Text(template.authorName)
                        .font(PRTypography.labelSmall)
                        .foregroundColor(.prGray60)
                }

                // タイトル
                Text(template.title)
                    .font(PRTypography.bodyMedium)
                    .foregroundColor(.prGray100)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // プロンプトプレビュー
                Text(template.promptText)
                    .font(PRTypography.labelSmall)
                    .foregroundColor(.prGray60)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer()

                // 統計情報
                HStack(spacing: PRSpacing.md) {
                    ReactionBadge(
                        icon: "heart.fill",
                        value: template.likeCount,
                        color: .prCoral
                    )

                    ReactionBadge(
                        icon: "arrow.up.circle.fill",
                        value: template.useCount,
                        color: .prCategoryBlue,
                        label: "Use"
                    )

                    Spacer()

                    Text(formatDate(template.createdAt))
                        .font(PRTypography.labelSmall)
                        .foregroundColor(.prGray40)
                }
            }

            // 右側：正方形サムネイル
            AsyncImage(url: URL(string: template.sampleImageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.prGray10)
                        .frame(width: 100, height: 100)
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(Color.prGray10)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundColor(.prGray40)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .cornerRadius(PRRadius.sm)
        }
        .padding(PRSpacing.md)
        .background(Color.white)
        .cornerRadius(PRRadius.md)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}

// MARK: - Reaction Badge
private struct ReactionBadge: View {
    let icon: String
    let value: Int
    let color: Color
    var label: String? = nil

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text(formatCount(value))
                .font(PRTypography.labelSmall)
                .foregroundColor(.prGray60)
            if let label {
                Text(label)
                    .font(PRTypography.labelSmall)
                    .foregroundColor(.prGray40)
            }
        }
    }

    private func formatCount(_ value: Int) -> String {
        if value >= 1000 {
            return String(format: "%.1fk", Double(value) / 1000)
        }
        return "\(value)"
    }
}

#Preview {
    NavigationStack {
        ImagePromptListView()
            .environmentObject(PromptStore())
    }
}
