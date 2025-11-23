//
//  PromptCard.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI

struct PromptCard: View {
    let prompt: Prompt
    @EnvironmentObject var store: PromptStore

    var body: some View {
        VStack(alignment: .leading, spacing: PRSpacing.sm) {
            // カテゴリドット + タイトル
            HStack(alignment: .top, spacing: PRSpacing.xs) {
                // カテゴリカラードット
                Circle()
                    .fill(categoryColor)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)

                // タイトル
                Text(prompt.title)
                    .font(PRTypography.headlineMedium)
                    .foregroundColor(.prGray100)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // プロンプト本文プレビュー
            Text(prompt.body)
                .font(PRTypography.bodySmall)
                .foregroundColor(.prGray60)
                .lineLimit(2)
                .padding(.leading, PRSpacing.md)

            // メタ情報
            HStack {
                // 作成者
                HStack(spacing: 4) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.prGray40)
                    Text(prompt.authorName)
                        .font(PRTypography.labelSmall)
                        .foregroundColor(.prGray60)
                }

                Spacer()

                // いいね・使用回数
                HStack(spacing: PRSpacing.sm) {
                    HStack(spacing: 2) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.prCoral)
                        Text(formatCount(prompt.likeCount))
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray60)
                    }

                    HStack(spacing: 2) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.prOrange)
                        Text(formatCount(prompt.useCount))
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray60)
                    }
                }
            }
            .padding(.leading, PRSpacing.md)
        }
        .padding(PRSpacing.md)
        .background(Color.white)
        .cornerRadius(PRRadius.lg)
        .prShadow(PRShadow.md)
    }

    private var categoryColor: Color {
        guard let category = store.category(for: prompt.categoryId) else {
            return .prGray40
        }
        switch category.name {
        case "ビジネス": return .prCategoryBlue
        case "マーケティング": return .prCategoryPurple
        case "ライティング": return .prCategoryGreen
        case "学習・教育": return .prCategoryTeal
        case "プログラミング": return .prCategoryBlue
        case "日常・生活": return .prCategoryAmber
        case "クリエイティブ": return .prCategoryPurple
        case "分析・リサーチ": return .prCategoryTeal
        default: return .prGray40
        }
    }

    private func formatCount(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000)
        }
        return "\(count)"
    }
}

// MARK: - Badge Component
struct PRBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(PRTypography.labelSmall)
            .padding(.horizontal, PRSpacing.xs)
            .padding(.vertical, PRSpacing.xxs)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(PRRadius.xs)
    }
}

// Legacy Badge for compatibility
struct Badge: View {
    let text: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(PRTypography.labelSmall)
        }
        .padding(.horizontal, PRSpacing.xs)
        .padding(.vertical, PRSpacing.xxs)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .cornerRadius(PRRadius.xs)
    }
}

// MARK: - Feature Card (Today's Pickup)
struct PromptFeatureCard: View {
    let prompt: Prompt
    @EnvironmentObject var store: PromptStore

    var body: some View {
        VStack(alignment: .leading, spacing: PRSpacing.sm) {
            Spacer()

            Text(prompt.title)
                .font(PRTypography.displaySmall)
                .foregroundColor(.white)
                .lineLimit(2)

            if let category = store.category(for: prompt.categoryId) {
                Text(category.name)
                    .font(PRTypography.labelMedium)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            // Ghost button
            HStack {
                Spacer()
                Text("使う")
                    .font(PRTypography.labelLarge)
                    .foregroundColor(.white)
                    .padding(.horizontal, PRSpacing.md)
                    .padding(.vertical, PRSpacing.xs)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(PRRadius.sm)
            }
        }
        .padding(PRSpacing.lg)
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(
            LinearGradient(
                colors: [.prOrange, .prCoral],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(PRRadius.xl)
        .prShadow(PRShadow.lg)
    }
}

// MARK: - Compact Card for Horizontal Scroll
struct PromptCardCompact: View {
    let prompt: Prompt
    @EnvironmentObject var store: PromptStore

    var body: some View {
        VStack(alignment: .leading, spacing: PRSpacing.xs) {
            Text(prompt.title)
                .font(PRTypography.headlineSmall)
                .foregroundColor(.prGray100)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            if let category = store.category(for: prompt.categoryId) {
                Text(category.name)
                    .font(PRTypography.labelSmall)
                    .foregroundColor(.prCategoryBlue)
            }

            Spacer()

            HStack(spacing: 2) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.prCoral)
                Text("\(prompt.likeCount)")
                    .font(PRTypography.labelSmall)
                    .foregroundColor(.prGray60)
            }
        }
        .padding(PRSpacing.sm)
        .frame(width: 150, height: 120)
        .background(Color.white)
        .cornerRadius(PRRadius.md)
        .prShadow(PRShadow.sm)
    }
}

#Preview {
    let store = PromptStore()
    return ScrollView {
        VStack(spacing: 16) {
            if let prompt = store.prompts.first {
                PromptFeatureCard(prompt: prompt)
                    .padding(.horizontal)

                PromptCard(prompt: prompt)
                    .padding(.horizontal)

                PromptCardCompact(prompt: prompt)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    .background(Color.prGray5)
    .environmentObject(store)
}
