//
//  WorkflowListView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI

struct WorkflowListView: View {
    @EnvironmentObject var store: PromptStore
    @State private var selectedWorkflow: Workflow?
    @State private var selectedTag: String?
    @State private var sortType: WorkflowSortType = .popular

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

                        ForEach(WorkflowTag.allCases, id: \.self) { tag in
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
                        ForEach(WorkflowSortType.allCases, id: \.self) { type in
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

                // ワークフローリスト
                if filteredAndSortedWorkflows.isEmpty {
                    WorkflowEmptyView()
                } else {
                    LazyVStack(spacing: PRSpacing.md) {
                        ForEach(filteredAndSortedWorkflows) { workflow in
                            Button(action: { selectedWorkflow = workflow }) {
                                WorkflowListCard(workflow: workflow)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, PRSpacing.md)
                    .padding(.bottom, 80)
                }
            }
        }
        .background(Color.prGray5)
        .navigationDestination(item: $selectedWorkflow) { workflow in
            WorkflowDetailView(workflow: workflow)
        }
    }

    private var filteredAndSortedWorkflows: [Workflow] {
        var workflows = store.workflows

        // タグフィルター
        if let tag = selectedTag {
            workflows = workflows.filter { $0.tags.contains(tag) }
        }

        // ソート
        switch sortType {
        case .newest:
            workflows.sort { $0.createdAt > $1.createdAt }
        case .popular:
            workflows.sort { $0.likeCount > $1.likeCount }
        case .liked:
            let likedIds: Set<UUID> = Set(
                store.workflowLikes
                    .filter { $0.userId == store.currentUserIdString }
                    .compactMap { UUID(uuidString: $0.workflowId) }
            )
            workflows = workflows.filter { likedIds.contains($0.id) }
        }

        return workflows
    }
}

// MARK: - Workflow Sort Type
enum WorkflowSortType: String, CaseIterable {
    case newest = "新着"
    case popular = "人気"
    case liked = "自分のいいね"
}

// MARK: - Workflow Tag
enum WorkflowTag: String, CaseIterable {
    case writing = "ライティング"
    case coding = "コーディング"
    case research = "リサーチ"
    case analysis = "分析"
    case creative = "クリエイティブ"
    case business = "ビジネス"
}

// MARK: - Workflow List Card
struct WorkflowListCard: View {
    let workflow: Workflow
    @EnvironmentObject var store: PromptStore

    var body: some View {
        VStack(alignment: .leading, spacing: PRSpacing.sm) {
            // タイトル
            Text(workflow.title)
                .font(PRTypography.bodyMedium)
                .foregroundColor(.prGray100)
                .lineLimit(2)

            // 投稿者・日時
            HStack(spacing: PRSpacing.xs) {
                Text("@\(workflow.authorName)")
                    .font(PRTypography.labelSmall)
                    .foregroundColor(.prGray60)

                Text("•")
                    .foregroundColor(.prGray40)

                Text(formatDate(workflow.createdAt))
                    .font(PRTypography.labelSmall)
                    .foregroundColor(.prGray40)
            }

            // ステップ数
            HStack(spacing: PRSpacing.xxs) {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.system(size: 12))
                    .foregroundColor(.prCategoryBlue)
                Text("\(workflow.steps.count)ステップ")
                    .font(PRTypography.labelSmall)
                    .foregroundColor(.prGray60)
            }

            // タグ
            HStack(spacing: PRSpacing.xxs) {
                ForEach(workflow.tags.prefix(3), id: \.self) { tag in
                    Text(tag)
                        .font(PRTypography.labelSmall)
                        .foregroundColor(.prCategoryBlue)
                        .padding(.horizontal, PRSpacing.xxs)
                        .padding(.vertical, 2)
                        .background(Color.prCategoryBlue.opacity(0.1))
                        .cornerRadius(PRRadius.xs)
                }
            }

            // 説明
            if !workflow.description.isEmpty {
                Text(workflow.description)
                    .font(PRTypography.bodySmall)
                    .foregroundColor(.prGray60)
                    .lineLimit(2)
            }

            // 統計
            HStack(spacing: PRSpacing.md) {
                HStack(spacing: 4) {
                    Image(systemName: store.isWorkflowLiked(workflow.id) ? "heart.fill" : "heart")
                        .font(.system(size: 12))
                        .foregroundColor(store.isWorkflowLiked(workflow.id) ? .prCoral : .prGray40)
                    Text("\(workflow.likeCount)")
                        .font(PRTypography.labelSmall)
                        .foregroundColor(.prGray60)
                }

                HStack(spacing: 4) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.prCategoryBlue)
                    Text("\(workflow.useCount)")
                        .font(PRTypography.labelSmall)
                        .foregroundColor(.prGray60)
                }

                Spacer()

                Text("実行する")
                    .font(PRTypography.labelSmall)
                    .foregroundColor(.prOrange)
            }
        }
        .padding(PRSpacing.md)
        .background(Color.white)
        .cornerRadius(PRRadius.md)
        .prShadow(PRShadow.sm)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Workflow Empty View
struct WorkflowEmptyView: View {
    var body: some View {
        VStack(spacing: PRSpacing.md) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 48))
                .foregroundColor(.prGray40)

            Text("No workflows")
                .font(PRTypography.headlineMedium)
                .foregroundColor(.prGray100)

            Text("Workflows allow you to execute\nmultiple prompt steps in sequence")
                .font(PRTypography.bodySmall)
                .foregroundColor(.prGray60)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(PRSpacing.xxl)
    }
}

#Preview {
    NavigationStack {
        WorkflowListView()
            .environmentObject(PromptStore())
    }
}
