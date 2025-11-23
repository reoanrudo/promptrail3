//
//  WorkflowDetailView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI

struct WorkflowDetailView: View {
    let workflow: Workflow
    @EnvironmentObject var store: PromptStore
    @Environment(\.dismiss) private var dismiss
    @State private var showExecutionView = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PRSpacing.lg) {
                // ヘッダー
                VStack(alignment: .leading, spacing: PRSpacing.sm) {
                    Text(workflow.title)
                        .font(PRTypography.headlineMedium)
                        .foregroundColor(.prGray100)

                    // 投稿者情報
                    HStack(spacing: PRSpacing.xs) {
                        Text("@\(workflow.authorName)")
                            .font(PRTypography.labelMedium)
                            .foregroundColor(.prGray60)

                        Text("•")
                            .foregroundColor(.prGray40)

                        Text(formatDate(workflow.createdAt))
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray40)
                    }

                    // タグ
                    FlowLayout(spacing: PRSpacing.xs) {
                        ForEach(workflow.tags, id: \.self) { tag in
                            Text(tag)
                                .font(PRTypography.labelSmall)
                                .foregroundColor(.prCategoryBlue)
                                .padding(.horizontal, PRSpacing.xs)
                                .padding(.vertical, 4)
                                .background(Color.prCategoryBlue.opacity(0.1))
                                .cornerRadius(PRRadius.xs)
                        }
                    }
                }
                .padding(.horizontal, PRSpacing.md)

                // 説明
                if !workflow.description.isEmpty {
                    VStack(alignment: .leading, spacing: PRSpacing.xs) {
                        Text("説明")
                            .font(PRTypography.labelMedium)
                            .foregroundColor(.prGray60)

                        Text(workflow.description)
                            .font(PRTypography.bodyMedium)
                            .foregroundColor(.prGray80)
                    }
                    .padding(.horizontal, PRSpacing.md)
                }

                // 実行ボタン
                Button(action: {
                    store.recordWorkflowUsage(workflow.id)
                    showExecutionView = true
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("実行")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PRPrimaryButtonStyle())
                .padding(.horizontal, PRSpacing.md)

                // いいねボタン
                Button(action: {
                    store.toggleWorkflowLike(workflow.id)
                }) {
                    HStack {
                        Image(systemName: store.isWorkflowLiked(workflow.id) ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                        Text(store.isWorkflowLiked(workflow.id) ? "いいね済み" : "いいね")
                            .font(PRTypography.labelMedium)
                    }
                    .foregroundColor(store.isWorkflowLiked(workflow.id) ? .prCoral : .prGray60)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(PRRadius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: PRRadius.md)
                            .stroke(store.isWorkflowLiked(workflow.id) ? Color.prCoral : Color.prGray20, lineWidth: 1.5)
                    )
                }
                .padding(.horizontal, PRSpacing.md)

                // ステップ一覧
                VStack(alignment: .leading, spacing: PRSpacing.sm) {
                    Text("ステップ (\(workflow.steps.count))")
                        .font(PRTypography.labelMedium)
                        .foregroundColor(.prGray60)
                        .padding(.horizontal, PRSpacing.md)

                    VStack(spacing: 0) {
                        ForEach(Array(workflow.steps.enumerated()), id: \.element.id) { index, step in
                            WorkflowStepPreview(step: step, stepNumber: index + 1, isLast: index == workflow.steps.count - 1)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(PRRadius.md)
                    .padding(.horizontal, PRSpacing.md)
                }

                // 統計
                HStack(spacing: PRSpacing.lg) {
                    VStack(alignment: .center, spacing: PRSpacing.xxs) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.prCoral)
                            Text("\(workflow.likeCount)")
                                .font(PRTypography.headlineSmall)
                                .foregroundColor(.prGray100)
                        }
                        Text("いいね")
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray40)
                    }

                    VStack(alignment: .center, spacing: PRSpacing.xxs) {
                        HStack(spacing: 4) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.prCategoryBlue)
                            Text("\(workflow.useCount)")
                                .font(PRTypography.headlineSmall)
                                .foregroundColor(.prGray100)
                        }
                        Text("実行")
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray40)
                    }

                    Spacer()
                }
                .padding(.horizontal, PRSpacing.md)
            }
            .padding(.top, PRSpacing.md)
            .padding(.bottom, 80)
        }
        .background(Color.prGray5)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showExecutionView) {
            WorkflowExecutionView(workflow: workflow)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Workflow Step Preview
struct WorkflowStepPreview: View {
    let step: WorkflowStep
    let stepNumber: Int
    let isLast: Bool

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ステップヘッダー
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack(spacing: PRSpacing.sm) {
                    // ステップ番号
                    Text("\(stepNumber)")
                        .font(PRTypography.labelMedium)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.prOrange)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(step.name)
                            .font(PRTypography.bodyMedium)
                            .foregroundColor(.prGray100)

                        if !step.description.isEmpty {
                            Text(step.description)
                                .font(PRTypography.labelSmall)
                                .foregroundColor(.prGray60)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.prGray40)
                }
                .padding(PRSpacing.md)
            }

            // 展開コンテンツ（プロンプトテンプレートは非表示）
            if isExpanded {
                VStack(alignment: .leading, spacing: PRSpacing.sm) {
                    // ステップの機能説明（プロンプト全文は見せない）
                    VStack(alignment: .leading, spacing: PRSpacing.xs) {
                        HStack(spacing: PRSpacing.xxs) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.prOrange)
                            Text("このステップの機能")
                                .font(PRTypography.labelSmall)
                                .foregroundColor(.prOrange)
                                .fontWeight(.semibold)
                        }

                        Text("「このワークフローを実行」から詳細な指示を確認できます")
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray60)
                    }
                    .padding(PRSpacing.sm)
                    .background(Color.prOrange.opacity(0.1))
                    .cornerRadius(PRRadius.sm)

                    // 入力フィールド
                    if !step.inputsSchema.isEmpty {
                        HStack(spacing: PRSpacing.xxs) {
                            Image(systemName: "text.cursor")
                                .font(.system(size: 10))
                                .foregroundColor(.prGray40)
                            Text("\(step.inputsSchema.count)個の入力フィールド")
                                .font(PRTypography.labelSmall)
                                .foregroundColor(.prGray60)
                        }
                    }

                    // ペースト要求
                    if step.requireUserPaste {
                        HStack(spacing: PRSpacing.xxs) {
                            Image(systemName: "doc.on.clipboard")
                                .font(.system(size: 10))
                                .foregroundColor(.prGray40)
                            Text("AIの回答をペースト")
                                .font(PRTypography.labelSmall)
                                .foregroundColor(.prGray60)
                        }
                    }

                    // 遷移条件
                    if !step.transitions.isEmpty {
                        HStack(spacing: PRSpacing.xxs) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 10))
                                .foregroundColor(.prGray40)
                            Text("\(step.transitions.count)個の分岐")
                                .font(PRTypography.labelSmall)
                                .foregroundColor(.prGray60)
                        }
                    }
                }
                .padding(.horizontal, PRSpacing.md)
                .padding(.bottom, PRSpacing.md)
            }

            if !isLast {
                Divider()
                    .padding(.leading, 56)
            }
        }
    }
}

#Preview {
    NavigationStack {
        WorkflowDetailView(workflow: Workflow(
            title: "ブログ記事作成ワークフロー",
            description: "トピックからアウトライン、本文、推敲まで段階的に記事を作成します",
            steps: [
                WorkflowStep(
                    name: "アウトライン作成",
                    description: "トピックからアウトラインを生成",
                    promptTemplate: "{topic}について、以下の構成でアウトラインを作成してください:\n\n1. 導入\n2. 本文（3-5セクション）\n3. まとめ",
                    inputsSchema: [
                        WorkflowInputField(label: "トピック", placeholder: "記事のテーマ", required: true)
                    ]
                ),
                WorkflowStep(
                    name: "本文執筆",
                    description: "アウトラインに基づいて本文を執筆",
                    promptTemplate: "以下のアウトラインに基づいて、各セクションの本文を執筆してください:\n\n{outline}",
                    requireUserPaste: true
                ),
                WorkflowStep(
                    name: "推敲・校正",
                    description: "文章を推敲し、改善点を提案",
                    promptTemplate: "以下の文章を推敲し、より読みやすく改善してください:\n\n{draft}",
                    requireUserPaste: true
                )
            ],
            tags: ["ライティング", "ブログ"],
            likeCount: 42,
            useCount: 128,
            authorName: "writer_pro"
        ))
        .environmentObject(PromptStore())
    }
}
