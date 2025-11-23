//
//  MyPromptsView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI

// MARK: - My Page Tab Type
enum MyPageTab: String, CaseIterable {
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

struct MyPromptsView: View {
    @EnvironmentObject var store: PromptStore
    @AppStorage("myPageSelectedTab") private var storedTabRawValue: String = MyPageTab.quick.rawValue
    @State private var selectedTab: MyPageTab = .quick
    @State private var searchText = ""
    @State private var selectedFolder: UUID?
    @State private var selectedTemplate: MyTemplate?
    @State private var showCreateFolder = false
    @State private var newFolderName = ""
    @State private var showCreateSheet = false
    @State private var selectedTemplateForDetail: MyTemplate?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // マイページ専用検索バー
                MySearchBar(text: $searchText)
                    .padding(.horizontal, PRSpacing.md)
                    .padding(.top, PRSpacing.sm)

                // 子タブセレクター
                Picker("", selection: $selectedTab) {
                    ForEach(MyPageTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, PRSpacing.md)
                .padding(.vertical, PRSpacing.sm)

                Divider()

                // コンテンツ（タブ別）
                switch selectedTab {
                case .quick:
                    MyQuickPromptsView(searchText: searchText)
                case .workflow:
                    MyWorkflowsView(searchText: searchText)
                case .picture:
                    MyPicturePromptsView(searchText: searchText)
                }
            }
            .background(Color.prBackground)
            .alert("フォルダを作成", isPresented: $showCreateFolder) {
                TextField("フォルダ名", text: $newFolderName)
                Button("作成") {
                    if !newFolderName.isEmpty {
                        store.createFolder(name: newFolderName)
                        newFolderName = ""
                    }
                }
                Button("キャンセル", role: .cancel) {
                    newFolderName = ""
                }
            }
            .onAppear {
                selectedTab = MyPageTab(rawValue: storedTabRawValue) ?? .quick
            }
            .onChange(of: selectedTab) { oldValue, newValue in
                storedTabRawValue = newValue.rawValue
            }
        }
    }
}

// MARK: - My Quick Prompts View
struct MyQuickPromptsView: View {
    @EnvironmentObject var store: PromptStore
    let searchText: String
    @State private var selectedTemplate: MyTemplate?
    @State private var templatePendingDeletion: MyTemplate?
    @State private var showDeletionToast = false

    var body: some View {
        ZStack(alignment: .bottom) {
            content

            if showDeletionToast {
                DeletionToastView(message: "削除しました")
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .confirmationDialog(
            "このテンプレートを削除しますか？",
            isPresented: Binding(
                get: { templatePendingDeletion != nil },
                set: { if !$0 { templatePendingDeletion = nil } }
            ),
            presenting: templatePendingDeletion
        ) { template in
            Button("削除", role: .destructive) {
                confirmDeletion(template)
            }
            Button("キャンセル", role: .cancel) {
                templatePendingDeletion = nil
            }
        } message: { _ in
            Text("マイページにのみ保存されたコピーが削除されます。")
        }
    }

    @ViewBuilder
    private var content: some View {
        let templates = filteredTemplates

        if templates.isEmpty {
            PREmptyState(
                icon: "doc.text",
                title: "No saved prompts",
                message: "Save prompts from the Fast tab"
            )
        } else {
            ScrollView {
                LazyVStack(spacing: PRSpacing.sm) {
                    ForEach(templates) { template in
                        ZStack(alignment: .topTrailing) {
                            Button(action: { selectedTemplate = template }) {
                                MyTemplateRow(template: template)
                            }
                            .buttonStyle(.plain)

                            CardDeleteButton {
                                templatePendingDeletion = template
                            }
                            .padding(8)
                        }
                        .contextMenu {
                            Button("開く") {
                                selectedTemplate = template
                            }
                            Button("編集") {
                                selectedTemplate = template
                            }
                            Button("複製") {
                                store.duplicateMyTemplate(template)
                            }
                            Button(role: .destructive) {
                                templatePendingDeletion = template
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(PRSpacing.md)
                .padding(.bottom, 80)
            }
            .navigationDestination(item: $selectedTemplate) { template in
                MyTemplateDetailView(template: template)
            }
        }
    }

    private var filteredTemplates: [MyTemplate] {
        var templates = store.myTemplates

        // Quickタイプのテンプレートのみフィルタリング
        templates = templates.filter { template in
            store.getTemplateSourceType(template) == .quick
        }

        if !searchText.isEmpty {
            templates = templates.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        return templates
    }

    private func confirmDeletion(_ template: MyTemplate) {
        store.deleteMyTemplate(template.id)
        templatePendingDeletion = nil
        showToast()
    }

    private func showToast() {
        withAnimation {
            showDeletionToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showDeletionToast = false
            }
        }
    }
}

// MARK: - My Workflows View
struct MyWorkflowsView: View {
    @EnvironmentObject var store: PromptStore
    let searchText: String
    @State private var selectedTemplate: MyTemplate?
    @State private var templatePendingDeletion: MyTemplate?
    @State private var showDeletionToast = false

    var body: some View {
        ZStack(alignment: .bottom) {
            content

            if showDeletionToast {
                DeletionToastView(message: "削除しました")
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .confirmationDialog(
            "このテンプレートを削除しますか？",
            isPresented: Binding(
                get: { templatePendingDeletion != nil },
                set: { if !$0 { templatePendingDeletion = nil } }
            ),
            presenting: templatePendingDeletion
        ) { template in
            Button("削除", role: .destructive) {
                confirmDeletion(template)
            }
            Button("キャンセル", role: .cancel) {
                templatePendingDeletion = nil
            }
        } message: { _ in
            Text("マイページに保存したテンプレートのみ削除されます。")
        }
        .navigationDestination(item: $selectedTemplate) { template in
            MyTemplateDetailView(template: template)
        }
    }

    @ViewBuilder
    private var content: some View {
        let templates = filteredTemplates

        if templates.isEmpty {
            PREmptyState(
                icon: "list.bullet.rectangle",
                title: "No saved workflows",
                message: "Save workflows from the Workflow tab"
            )
        } else {
            ScrollView {
                LazyVStack(spacing: PRSpacing.sm) {
                    ForEach(templates) { template in
                        ZStack(alignment: .topTrailing) {
                            Button(action: { selectedTemplate = template }) {
                                MyTemplateRow(template: template)
                            }
                            .buttonStyle(.plain)

                            CardDeleteButton {
                                templatePendingDeletion = template
                            }
                            .padding(8)
                        }
                        .contextMenu {
                            Button("開く") {
                                selectedTemplate = template
                            }
                            Button("編集") {
                                selectedTemplate = template
                            }
                            Button("複製") {
                                store.duplicateMyTemplate(template)
                            }
                            Button(role: .destructive) {
                                templatePendingDeletion = template
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(PRSpacing.md)
                .padding(.bottom, 80)
            }
        }
    }

    private var filteredTemplates: [MyTemplate] {
        var templates = store.myTemplates

        // Workflowタイプのテンプレートのみフィルタリング
        templates = templates.filter { template in
            store.getTemplateSourceType(template) == .workflow
        }

        if !searchText.isEmpty {
            templates = templates.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        return templates
    }

    private func confirmDeletion(_ template: MyTemplate) {
        store.deleteMyTemplate(template.id)
        templatePendingDeletion = nil
        showToast()
    }

    private func showToast() {
        withAnimation {
            showDeletionToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showDeletionToast = false
            }
        }
    }
}

// MARK: - Workflow Card
struct WorkflowCard: View {
    let workflow: Workflow

    var body: some View {
        VStack(alignment: .leading, spacing: PRSpacing.sm) {
            HStack {
                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 16))
                    .foregroundColor(.prCategoryTeal)

                Text(workflow.title)
                    .font(PRTypography.bodyMedium)
                    .foregroundColor(Color.prTextPrimary)
                    .lineLimit(1)

                Spacer()

                Text("\(workflow.steps.count)ステップ")
                    .font(PRTypography.labelSmall)
                    .foregroundColor(Color.prTextSecondary)
                    .padding(.horizontal, PRSpacing.xs)
                    .padding(.vertical, 2)
                    .background(Color.prCategoryTeal.opacity(0.1))
                    .cornerRadius(PRRadius.xs)
            }

            Text(workflow.description)
                .font(PRTypography.bodySmall)
                .foregroundColor(Color.prTextSecondary)
                .lineLimit(2)

            HStack(spacing: PRSpacing.xs) {
                ForEach(workflow.tags.prefix(3), id: \.self) { tag in
                    Text("#\(tag)")
                        .font(PRTypography.labelSmall)
                        .foregroundColor(Color.prTextTertiary)
                }
            }
        }
        .padding(PRSpacing.md)
        .background(Color.prCardBackground)
        .cornerRadius(PRRadius.md)
    }
}

// MARK: - My Picture Prompts View
struct MyPicturePromptsView: View {
    @EnvironmentObject var store: PromptStore
    let searchText: String
    @State private var selectedTemplate: MyTemplate?
    @State private var templatePendingDeletion: MyTemplate?
    @State private var showDeletionToast = false

    var body: some View {
        ZStack(alignment: .bottom) {
            content

            if showDeletionToast {
                DeletionToastView(message: "削除しました")
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .confirmationDialog(
            "このテンプレートを削除しますか？",
            isPresented: Binding(
                get: { templatePendingDeletion != nil },
                set: { if !$0 { templatePendingDeletion = nil } }
            ),
            presenting: templatePendingDeletion
        ) { template in
            Button("削除", role: .destructive) {
                confirmDeletion(template)
            }
            Button("キャンセル", role: .cancel) {
                templatePendingDeletion = nil
            }
        } message: { _ in
            Text("マイページの複製のみ削除されます。")
        }
        .navigationDestination(item: $selectedTemplate) { template in
            MyTemplateDetailView(template: template)
        }
    }

    @ViewBuilder
    private var content: some View {
        let templates = filteredTemplates

        if templates.isEmpty {
            PREmptyState(
                icon: "photo",
                title: "No saved picture prompts",
                message: "Save picture prompts from the Picture tab"
            )
        } else {
            ScrollView {
                LazyVStack(spacing: PRSpacing.sm) {
                    ForEach(templates) { template in
                        ZStack(alignment: .topTrailing) {
                            Button(action: { selectedTemplate = template }) {
                                MyPicturePromptCard(template: template)
                            }
                            .buttonStyle(.plain)

                            CardDeleteButton {
                                templatePendingDeletion = template
                            }
                            .padding(8)
                        }
                        .contextMenu {
                            Button("開く") {
                                selectedTemplate = template
                            }
                            Button("編集") {
                                selectedTemplate = template
                            }
                            Button("複製") {
                                store.duplicateMyTemplate(template)
                            }
                            Button(role: .destructive) {
                                templatePendingDeletion = template
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(PRSpacing.md)
                .padding(.bottom, 80)
            }
        }
    }

    private var filteredTemplates: [MyTemplate] {
        var templates = store.myTemplates

        // Pictureタイプのテンプレートのみフィルタリング
        templates = templates.filter { template in
            store.getTemplateSourceType(template) == .picture
        }

        if !searchText.isEmpty {
            templates = templates.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        return templates
    }

    private func confirmDeletion(_ template: MyTemplate) {
        store.deleteMyTemplate(template.id)
        templatePendingDeletion = nil
        showToast()
    }

    private func showToast() {
        withAnimation {
            showDeletionToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showDeletionToast = false
            }
        }
    }
}

// MARK: - My Search Bar
struct MySearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: PRSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundColor(.prGray40)

            TextField("マイテンプレを検索", text: $text)
                .font(PRTypography.bodySmall)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.prGray40)
                }
            }
        }
        .padding(.horizontal, PRSpacing.sm)
        .padding(.vertical, PRSpacing.xs)
        .background(Color.white)
        .cornerRadius(PRRadius.md)
    }
}

// MARK: - My Picture Prompt Card
private struct MyPicturePromptCard: View {
    let template: MyTemplate
    @EnvironmentObject var store: PromptStore

    var body: some View {
        HStack(alignment: .top, spacing: PRSpacing.md) {
            // 左側：テキスト情報
            VStack(alignment: .leading, spacing: PRSpacing.xs) {
                // タイトル
                Text(template.title)
                    .font(PRTypography.bodyMedium)
                    .foregroundColor(.prGray100)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // プロンプトプレビュー
                Text(template.body)
                    .font(PRTypography.labelSmall)
                    .foregroundColor(.prGray60)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer()

                // 日付のみ表示
                Text(formatDate(template.updatedAt))
                    .font(PRTypography.labelSmall)
                    .foregroundColor(.prGray40)
            }

            // 右側：正方形サムネイル
            AsyncImage(url: imageURL) { phase in
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
        .padding(PRSpacing.sm)
        .background(Color.white)
        .cornerRadius(PRRadius.md)
    }

    private var imageURL: URL? {
        if let sourceId = template.originalTemplateId,
           let source = store.imagePromptTemplates.first(where: { $0.id == sourceId }) {
            return URL(string: source.sampleImageUrl)
        }

        let urlString = template.sampleImageUrl ?? template.fullImageUrl
        guard let urlString, let url = URL(string: urlString) else {
            return nil
        }
        return url
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Folder Filter Chip
struct FolderFilterChip: View {
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

// MARK: - My Templates Content View
struct MyTemplatesContentView: View {
    @EnvironmentObject var store: PromptStore
    let searchText: String
    let selectedFolder: UUID?
    let onTapTemplate: (MyTemplate) -> Void
    @State private var pendingDeletion: MyTemplate?
    @State private var showDeletionToast = false

    var body: some View {
        ZStack(alignment: .bottom) {
            content

            if showDeletionToast {
                DeletionToastView(message: "削除しました")
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .confirmationDialog(
            "このプロンプトを削除しますか？",
            isPresented: Binding(
                get: { pendingDeletion != nil },
                set: { if !$0 { pendingDeletion = nil } }
            ),
            presenting: pendingDeletion
        ) { template in
            Button("削除", role: .destructive) {
                confirmDeletion(template)
            }
            Button("キャンセル", role: .cancel) {
                pendingDeletion = nil
            }
        } message: { _ in
            Text("マイページの複製のみ削除されます。")
        }
    }

    @ViewBuilder
    private var content: some View {
        let templates = filteredTemplates

        if templates.isEmpty {
            PREmptyState(
                icon: "doc.text",
                title: "マイテンプレがありません",
                message: "右下の「＋」ボタンから新しいテンプレを作成するか、\nホームからテンプレを複製してみましょう"
            )
        } else {
            ScrollView {
                LazyVStack(spacing: PRSpacing.xs) {
                    ForEach(templates) { template in
                        let canDelete = template.originalTemplateId != nil
                        ZStack(alignment: .topTrailing) {
                            Button(action: { onTapTemplate(template) }) {
                                MyTemplateRow(template: template)
                            }
                            .buttonStyle(.plain)

                            if canDelete {
                                CardDeleteButton {
                                    pendingDeletion = template
                                }
                                .padding(8)
                            }
                        }
                        .contextMenu {
                            Button("開く") {
                                onTapTemplate(template)
                            }
                            Button("編集") {
                                onTapTemplate(template)
                            }
                            Button("複製") {
                                store.duplicateMyTemplate(template)
                            }
                            if canDelete {
                                Button(role: .destructive) {
                                    pendingDeletion = template
                                } label: {
                                    Label("削除", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .padding(PRSpacing.md)
            }
        }
    }

    private var filteredTemplates: [MyTemplate] {
        var templates = store.myTemplates

        // フォルダフィルター
        if let folderId = selectedFolder {
            templates = templates.filter { $0.folderId == folderId }
        }

        // 検索フィルター
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            templates = templates.filter {
                $0.title.lowercased().contains(query) ||
                $0.body.lowercased().contains(query)
            }
        }

        return templates.sorted { $0.updatedAt > $1.updatedAt }
    }

    private func confirmDeletion(_ template: MyTemplate) {
        store.deleteMyTemplate(template.id)
        pendingDeletion = nil
        showToast()
    }

    private func showToast() {
        withAnimation {
            showDeletionToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showDeletionToast = false
            }
        }
    }
}

// MARK: - History Content View
struct HistoryContentView: View {
    @EnvironmentObject var store: PromptStore
    let searchText: String
    let onTapTemplate: (MyTemplate) -> Void

    var body: some View {
        let history = filteredHistory

        if history.isEmpty {
            PREmptyState(
                icon: "clock",
                title: "履歴がありません",
                message: "テンプレを使用すると、ここに履歴が表示されます"
            )
        } else {
            ScrollView {
                LazyVStack(spacing: PRSpacing.xs) {
                    ForEach(history) { item in
                        if let template = store.myTemplate(for: item.templateId) {
                            Button(action: { onTapTemplate(template) }) {
                                MyTemplateRow(
                                    template: template,
                                    subtitle: formatDate(item.usedAt)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(PRSpacing.md)
            }
        }
    }

    private var filteredHistory: [TemplateUsageHistory] {
        var history = store.templateUsageHistory

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            history = history.filter { item in
                guard let template = store.myTemplate(for: item.templateId) else { return false }
                return template.title.lowercased().contains(query) ||
                       template.body.lowercased().contains(query)
            }
        }

        return history
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - My Template Row
struct MyTemplateRow: View {
    let template: MyTemplate
    var subtitle: String? = nil
    @EnvironmentObject var store: PromptStore

    var body: some View {
        HStack(spacing: PRSpacing.md) {
            VStack(alignment: .leading, spacing: PRSpacing.xxs) {
                HStack(spacing: PRSpacing.xs) {
                    Text(template.title)
                        .font(PRTypography.bodyMedium)
                        .foregroundColor(.prGray100)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // 公開/非公開バッジ
                    if template.isPublic {
                        Text("公開")
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.white)
                            .padding(.horizontal, PRSpacing.xxs)
                            .padding(.vertical, 2)
                            .background(Color.prCategoryBlue)
                            .cornerRadius(PRRadius.xs)
                    }
                }

                HStack(spacing: PRSpacing.xs) {
                    if let category = store.category(for: template.categoryId) {
                        Text(category.name)
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prCategoryBlue)
                    }

                    if let subtitle = subtitle {
                        Text("•")
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray40)
                        Text(subtitle)
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray40)
                    } else {
                        Text("•")
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray40)
                        Text(formatDate(template.updatedAt))
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray40)
                    }

                    // 変数数
                    if !template.variables.isEmpty {
                        Text("•")
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray40)
                        Text("変数 \(template.variables.count)")
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray40)
                    }
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.prGray40)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PRSpacing.sm)
        .background(Color.white)
        .cornerRadius(PRRadius.md)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

}


// MARK: - Empty State
struct PREmptyState: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: PRSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.prGray40)

            Text(title)
                .font(PRTypography.headlineMedium)
                .foregroundColor(.prGray100)

            Text(message)
                .font(PRTypography.bodySmall)
                .foregroundColor(.prGray60)
                .multilineTextAlignment(.center)
        }
        .padding(PRSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Shared Toast
struct DeletionToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(PRTypography.labelMedium)
            .foregroundColor(.white)
            .padding(.horizontal, PRSpacing.lg)
            .padding(.vertical, PRSpacing.sm)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.75))
            )
            .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)
    }
}

#Preview {
    MyPromptsView()
        .environmentObject(PromptStore())
}
