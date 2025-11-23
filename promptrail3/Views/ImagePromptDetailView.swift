//
//  ImagePromptDetailView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI

struct ImagePromptDetailView: View {
    let template: ImagePromptTemplate
    @EnvironmentObject var store: PromptStore
    @Environment(\.dismiss) private var dismiss

    @State private var showCopyView = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // フル画像
                AsyncImage(url: URL(string: currentTemplate.fullImageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.prGray10)
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    case .failure:
                        Rectangle()
                            .fill(Color.prGray10)
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 60))
                                    .foregroundColor(.prGray40)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }

                VStack(alignment: .leading, spacing: PRSpacing.md) {
                    // タイトル
                    Text(currentTemplate.title)
                        .font(PRTypography.headlineLarge)
                        .foregroundColor(.prGray100)

                    // タグ
                    FlowLayout(spacing: PRSpacing.xxs) {
                        ForEach(currentTemplate.tags, id: \.self) { tag in
                            Text(tag)
                                .font(PRTypography.labelSmall)
                                .foregroundColor(.prCategoryBlue)
                                .padding(.horizontal, PRSpacing.xs)
                                .padding(.vertical, PRSpacing.xxs)
                                .background(Color.prCategoryBlue.opacity(0.1))
                                .cornerRadius(PRRadius.xs)
                        }
                    }

                    // リアクション
                    HStack(spacing: PRSpacing.lg) {
                        ReactionStat(
                            icon: "heart.fill",
                            value: currentTemplate.likeCount,
                            label: "リアクション",
                            color: .prCoral
                        )

                        ReactionStat(
                            icon: "arrow.up.circle.fill",
                            value: currentTemplate.useCount,
                            label: "Use数",
                            color: .prCategoryBlue
                        )

                        Spacer()
                    }

                    // モデル情報
                    HStack(spacing: PRSpacing.md) {
                        VStack(alignment: .leading, spacing: PRSpacing.xxs) {
                            Text("モデル")
                                .font(PRTypography.labelSmall)
                                .foregroundColor(.prGray40)
                            Text(currentTemplate.modelType.rawValue)
                                .font(PRTypography.bodyMedium)
                                .foregroundColor(.prGray80)
                        }

                        VStack(alignment: .leading, spacing: PRSpacing.xxs) {
                            Text("アスペクト比")
                                .font(PRTypography.labelSmall)
                                .foregroundColor(.prGray40)
                            Text(currentTemplate.aspectRatio.rawValue)
                                .font(PRTypography.bodyMedium)
                                .foregroundColor(.prGray80)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: PRSpacing.xxs) {
                            Text("作成者")
                                .font(PRTypography.labelSmall)
                                .foregroundColor(.prGray40)
                            Text(currentTemplate.authorName)
                                .font(PRTypography.bodyMedium)
                                .foregroundColor(.prGray80)
                        }
                    }
                    .padding(PRSpacing.sm)
                    .background(Color.prGray5)
                    .cornerRadius(PRRadius.sm)

                    // プロンプトヒント（全文は非表示）
                    VStack(alignment: .leading, spacing: PRSpacing.sm) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.prOrange)
                            Text("プロンプトの特徴")
                                .font(PRTypography.headlineSmall)
                                .fontWeight(.semibold)
                                .foregroundColor(.prGray100)
                        }

                        VStack(alignment: .leading, spacing: PRSpacing.sm) {
                            ForEach(getPromptFeatures(), id: \.self) { feature in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.prOrange)
                                        .font(.system(size: 14))
                                        .padding(.top, 2)

                                    Text(feature)
                                        .font(PRTypography.bodyMedium)
                                        .foregroundColor(.prGray80)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }

                            // プロンプトの文字数だけ表示
                            HStack {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 14))
                                    .foregroundColor(.prGray60)
                                Text("プロンプト文字数: \(currentTemplate.promptText.count)文字")
                                    .font(PRTypography.labelMedium)
                                    .foregroundColor(.prGray60)
                            }
                            .padding(.top, PRSpacing.xs)
                        }
                        .padding(PRSpacing.md)
                        .background(Color.prSurfaceElevated)
                        .cornerRadius(PRRadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: PRRadius.md)
                                .stroke(Color.prOrange.opacity(0.3), lineWidth: 1)
                        )
                    }

                    // アクションボタン
                    VStack(spacing: PRSpacing.sm) {
                        // このプロンプトを使うボタン
                        Button(action: {
                            showCopyView = true
                        }) {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                Text("このプロンプトを使う")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PRPrimaryButtonStyle())

                        // いいねボタン
                        Button(action: {
                            store.toggleImagePromptLike(template.id)
                        }) {
                            HStack {
                                Image(systemName: store.isImagePromptLiked(template.id) ? "heart.fill" : "heart")
                                    .font(.system(size: 16))
                                Text(store.isImagePromptLiked(template.id) ? "いいね済み" : "いいね")
                                    .font(PRTypography.labelMedium)
                            }
                            .foregroundColor(store.isImagePromptLiked(template.id) ? .prCoral : .prGray60)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(PRRadius.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: PRRadius.md)
                                    .stroke(store.isImagePromptLiked(template.id) ? Color.prCoral : Color.prGray20, lineWidth: 1.5)
                            )
                        }
                    }
                }
                .padding(PRSpacing.md)
            }
            .padding(.bottom, 80)
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCopyView) {
            ImagePromptCopyView(template: template)
                .environmentObject(store)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var currentTemplate: ImagePromptTemplate {
        store.imagePromptTemplates.first(where: { $0.id == template.id }) ?? template
    }

    private func getPromptFeatures() -> [String] {
        var features: [String] = []

        // モデルに基づいた特徴
        switch currentTemplate.modelType {
        case .midjourney:
            features.append("Midjourney v6に最適化された表現")
            features.append("高品質なビジュアル生成のためのパラメータ")
        case .dalle:
            features.append("DALL-E 3向けの自然言語記述")
            features.append("詳細で正確なイメージ生成")
        case .stableDiffusion:
            features.append("Stable Diffusion用の構造化プロンプト")
            features.append("カスタマイズ可能なスタイル設定")
        case .firefly:
            features.append("Adobe Firefly向けの商用利用可能な設定")
            features.append("安全なコンテンツ生成に最適化")
        case .gemini:
            features.append("Google Gemini向けの最新AI生成技術")
            features.append("高精度な画像理解と生成")
        case .other:
            features.append("汎用的なプロンプト設計")
            features.append("複数の画像生成AIで利用可能")
        }

        // アスペクト比の情報
        switch currentTemplate.aspectRatio {
        case .square:
            features.append("正方形フォーマット (1:1) での最適な構図")
        case .landscape:
            features.append("横長フォーマット (3:2) でのバランス構図")
        case .portrait:
            features.append("縦長フォーマット (2:3) での縦構図")
        case .wide:
            features.append("ワイドフォーマット (16:9) での広角表現")
        case .ultraWide:
            features.append("ウルトラワイド (21:9) でのシネマティック表現")
        }

        // 一般的な特徴
        features.append("プロフェッショナルな画像品質を実現")
        features.append("「このプロンプトを使う」からプロンプト全文を確認できます")

        return features
    }
}

// MARK: - ImagePromptCopyView
struct ImagePromptCopyView: View {
    let template: ImagePromptTemplate
    @EnvironmentObject var store: PromptStore
    @Environment(\.dismiss) private var dismiss
    @State private var showCopiedToast = false
    @State private var showSavedToast = false

    private var currentTemplate: ImagePromptTemplate {
        store.imagePromptTemplates.first(where: { $0.id == template.id }) ?? template
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PRSpacing.lg) {
                    // プロンプト全文表示
                    VStack(alignment: .leading, spacing: PRSpacing.sm) {
                        Text("プロンプト")
                            .font(PRTypography.headlineSmall)
                            .foregroundColor(.prGray100)

                        Text(currentTemplate.promptText)
                            .font(PRTypography.code)
                            .foregroundColor(.prGray80)
                            .textSelection(.enabled)
                            .padding(PRSpacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.prGray5)
                            .cornerRadius(PRRadius.md)
                    }
                    .padding(.horizontal, PRSpacing.md)

                    // 使用ガイド
                    VStack(alignment: .leading, spacing: PRSpacing.sm) {
                        HStack(spacing: PRSpacing.xs) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.prCategoryBlue)
                            Text("使い方")
                                .font(PRTypography.headlineSmall)
                                .foregroundColor(.prGray100)
                        }

                        VStack(alignment: .leading, spacing: PRSpacing.xs) {
                            Text("1. 「コピー」ボタンでプロンプトをコピー")
                                .font(PRTypography.bodyMedium)
                                .foregroundColor(.prGray80)
                            Text("2. \(currentTemplate.modelType.rawValue)を開く")
                                .font(PRTypography.bodyMedium)
                                .foregroundColor(.prGray80)
                            Text("3. プロンプト入力欄に貼り付けて生成")
                                .font(PRTypography.bodyMedium)
                                .foregroundColor(.prGray80)
                        }
                        .padding(PRSpacing.sm)
                        .background(Color.prCategoryBlue.opacity(0.05))
                        .cornerRadius(PRRadius.sm)
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

                        Button(action: saveToMyTemplates) {
                            HStack {
                                Image(systemName: showSavedToast ? "bookmark.fill" : "bookmark")
                                Text(showSavedToast ? "保存済み" : "マイページに保存")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PRSecondaryButtonStyle())

                        Button(action: {
                            store.toggleImagePromptLike(template.id)
                        }) {
                            HStack {
                                Image(systemName: store.isImagePromptLiked(template.id) ? "heart.fill" : "heart")
                                Text(store.isImagePromptLiked(template.id) ? "いいね済み" : "いいね")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(store.isImagePromptLiked(template.id) ? .prCoral : .prGray10)
                        .foregroundColor(store.isImagePromptLiked(template.id) ? .white : .prGray80)
                    }
                    .padding(.horizontal, PRSpacing.md)
                }
                .padding(.top, PRSpacing.md)
                .padding(.bottom, PRSpacing.xl)
            }
            .navigationTitle(currentTemplate.title)
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
        } message: {
            Text("画像生成AIに貼り付けて使用してください")
        }
        .alert("保存しました", isPresented: $showSavedToast) {
            Button("OK", role: .cancel) {}
        }
    }

    private func copyToClipboard() {
        UIPasteboard.general.string = currentTemplate.promptText
        store.recordImagePromptUsage(template.id)
        showCopiedToast = true
    }

    private func saveToMyTemplates() {
        store.duplicateImagePromptTemplate(template)
        showSavedToast = true
    }
}

// MARK: - Reaction Stat
private struct ReactionStat: View {
    let icon: String
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: PRSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(formatValue(value))
                    .font(PRTypography.headlineSmall)
                    .foregroundColor(.prGray100)
                Text(label)
                    .font(PRTypography.labelSmall)
                    .foregroundColor(.prGray60)
            }
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
        ImagePromptDetailView(
            template: ImagePromptTemplate(
                title: "サンプル画像プロンプト",
                promptText: "A beautiful sunset over the ocean, golden hour lighting, cinematic composition, 8k resolution, highly detailed",
                tags: ["風景", "自然", "サンセット"],
                sampleImageUrl: "https://example.com/sample.jpg",
                fullImageUrl: "https://example.com/full.jpg",
                modelType: .midjourney,
                aspectRatio: .landscape,
                likeCount: 123,
                authorName: "ImageCreator"
            )
        )
        .environmentObject(PromptStore())
    }
}
