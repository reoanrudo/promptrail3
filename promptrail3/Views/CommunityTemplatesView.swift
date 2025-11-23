//
//  CommunityTemplatesView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/20.
//

import SwiftUI

// MARK: - Template Type Tab
enum TemplateTypeTab: String, CaseIterable {
    case quick = "Fast"
    case workflow = "Workflow"
    case picture = "Picture"

    var icon: String {
        switch self {
        case .quick: return "doc.text"
        case .workflow: return "list.bullet.rectangle"
        case .picture: return "photo"
        }
    }
}

struct CommunityTemplatesView: View {
    @EnvironmentObject var store: PromptStore
    @State private var searchText = ""
    @State private var selectedTab: TemplateTypeTab = .quick

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 検索バー
                HStack(spacing: PRSpacing.xs) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                        .foregroundColor(Color.prTextTertiary)

                    TextField("Search prompts...", text: $searchText)
                        .font(PRTypography.bodySmall)
                        .foregroundColor(Color.prTextPrimary)

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
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
                .padding(.horizontal, PRSpacing.md)
                .padding(.top, PRSpacing.sm)

                // タイプタブ（セグメント式）
                Picker("", selection: $selectedTab) {
                    ForEach(TemplateTypeTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, PRSpacing.md)
                .padding(.vertical, PRSpacing.sm)

                Divider()

                switch selectedTab {
                case .quick:
                    CommunityQuickPromptsView(searchText: searchText)
                case .workflow:
                    CommunityWorkflowsView(searchText: searchText)
                case .picture:
                    CommunityPicturePromptsView(searchText: searchText)
                }
            }
            .background(Color.prBackground)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Community Quick Prompts View
struct CommunityQuickPromptsView: View {
    @EnvironmentObject var store: PromptStore
    let searchText: String
    @State private var selectedPrompt: QuickPrompt?
    @State private var selectedCategories: Set<QuickCategory> = []
    @State private var isLoading = false
    @State private var loadError: String?

    var body: some View {
        VStack(spacing: 0) {
            // カテゴリタブ
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PRSpacing.sm) {
                    CategoryTab(
                        title: "All",
                        icon: "square.grid.2x2",
                        isSelected: selectedCategories.isEmpty,
                        action: { selectedCategories.removeAll() }
                    )

                    ForEach(QuickCategory.allCases, id: \.self) { category in
                        CategoryTab(
                            title: category.rawValue,
                            icon: category.icon,
                            isSelected: selectedCategories.contains(category),
                            action: { toggleCategory(category) }
                        )
                    }
                }
                .padding(.horizontal, PRSpacing.md)
                .padding(.vertical, PRSpacing.sm)
            }

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
        .navigationDestination(item: $selectedPrompt) { prompt in
            QuickPromptDetailView(prompt: prompt)
        }
        .task {
            await loadQuickPrompts()
        }
        .alert("読み込みに失敗しました", isPresented: Binding(
            get: { loadError != nil },
            set: { if !$0 { loadError = nil } }
        )) {
            Button("OK", role: .cancel) { loadError = nil }
        } message: {
            Text(loadError ?? "")
        }
    }

    private var filteredPrompts: [QuickPrompt] {
        var prompts = store.quickPrompts

        // カテゴリフィルター
        if !selectedCategories.isEmpty {
            prompts = prompts.filter { selectedCategories.contains($0.category) }
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

    private func loadQuickPrompts() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await store.loadCommunityQuickPrompts()
        } catch {
            await MainActor.run {
                loadError = error.localizedDescription
            }
        }
    }

    private func toggleCategory(_ category: QuickCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}

// MARK: - Community Workflows View
struct CommunityWorkflowsView: View {
    @EnvironmentObject var store: PromptStore
    let searchText: String
    @State private var selectedWorkflow: Workflow?
    @State private var selectedTag: String?
    @State private var sortType: WorkflowSortType = .popular
    @State private var isLoading = false
    @State private var loadError: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // タグフィルター
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: PRSpacing.xs) {
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
        .navigationDestination(item: $selectedWorkflow) { workflow in
            WorkflowDetailView(workflow: workflow)
        }
        .task {
            await loadWorkflows()
        }
        .alert("読み込みに失敗しました", isPresented: Binding(
            get: { loadError != nil },
            set: { if !$0 { loadError = nil } }
        )) {
            Button("OK", role: .cancel) { loadError = nil }
        } message: {
            Text(loadError ?? "")
        }
    }

    private var filteredAndSortedWorkflows: [Workflow] {
        var workflows = store.workflows

        // タグフィルター
        if let tag = selectedTag {
            workflows = workflows.filter { $0.tags.contains(tag) }
        }

        // 検索フィルター
        if !searchText.isEmpty {
            workflows = workflows.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
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

    private func loadWorkflows() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await store.loadCommunityWorkflows()
        } catch {
            await MainActor.run {
                loadError = error.localizedDescription
            }
        }
    }
}

// MARK: - Community Picture Prompts View
struct CommunityPicturePromptsView: View {
    @EnvironmentObject var store: PromptStore
    let searchText: String
    @State private var selectedTemplate: ImagePromptTemplate?
    @State private var selectedTags: Set<String> = []
    @State private var isLoading = false
    @State private var loadError: String?

    var body: some View {
        VStack(spacing: 0) {
            // タグフィルター
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PRSpacing.xs) {
                    ImageTagChip(
                        name: "すべて",
                        isSelected: selectedTags.isEmpty,
                        action: { selectedTags.removeAll() }
                    )

                    ForEach(ImageTag.allCases, id: \.self) { tag in
                        ImageTagChip(
                            name: tag.rawValue,
                            isSelected: selectedTags.contains(tag.rawValue),
                            action: { toggleTag(tag.rawValue) }
                        )
                    }
                }
                .padding(.horizontal, PRSpacing.md)
                .padding(.vertical, PRSpacing.sm)
            }

            // テンプレートリスト
            if filteredTemplates.isEmpty {
                PREmptyState(
                    icon: "photo",
                    title: "No picture prompts",
                    message: searchText.isEmpty ? "No picture prompts yet" : "No search results"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: PRSpacing.md) {
                        ForEach(filteredTemplates) { template in
                            ImagePromptCard(template: template)
                                .contentShape(RoundedRectangle(cornerRadius: PRRadius.md))
                                .onTapGesture {
                                    selectedTemplate = template
                                }
                        }
                    }
                    .padding(PRSpacing.md)
                    .padding(.bottom, 80)
                }
            }
        }
        .navigationDestination(item: $selectedTemplate) { template in
            ImagePromptDetailView(template: template)
        }
        .task {
            await loadPrompts()
        }
        .alert("読み込みに失敗しました", isPresented: Binding(
            get: { loadError != nil },
            set: { if !$0 { loadError = nil } }
        )) {
            Button("OK", role: .cancel) { loadError = nil }
        } message: {
            Text(loadError ?? "")
        }
    }

    private func loadPrompts() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await store.loadCommunityImagePrompts()
        } catch {
            await MainActor.run {
                loadError = error.localizedDescription
            }
        }
    }

    private var filteredTemplates: [ImagePromptTemplate] {
        var templates = store.imagePromptTemplates

        // タグフィルター（複数選択可）
        if !selectedTags.isEmpty {
            templates = templates.filter { template in
                !selectedTags.isDisjoint(with: Set(template.tags))
            }
        }

        // 検索フィルター
        if !searchText.isEmpty {
            templates = templates.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.promptText.localizedCaseInsensitiveContains(searchText)
            }
        }

        return templates
    }

    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
}

// MARK: - Image Tag Chip
struct ImageTagChip: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(PRTypography.labelMedium)
                .padding(.horizontal, PRSpacing.sm)
                .padding(.vertical, PRSpacing.xs)
                .background(isSelected ? Color.prOrange : Color.prCardBackground)
                .foregroundColor(isSelected ? .white : Color.prTextPrimary)
                .cornerRadius(PRRadius.pill)
        }
    }
}

#Preview {
    CommunityTemplatesView()
        .environmentObject(PromptStore())
}
