//
//  TemplateShareView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI

struct TemplateShareView: View {
    @EnvironmentObject var store: PromptStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var promptBody = ""
    @State private var promptDescription = ""
    @State private var selectedCategory: Category?
    @State private var selectedTask: PromptTask?
    @State private var selectedQuickCategory: QuickCategory?
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var authorName = "ユーザー"
    @State private var agreedToTerms = false
    @State private var agreedToContent = false
    @State private var showCategoryPicker = false
    @State private var showTaskPicker = false
    @State private var showQuickCategoryPicker = false
    @State private var showSuccessAlert = false

    // 詳細説明項目
    @State private var usageDescription = ""
    @State private var prerequisites = ""
    @State private var expectedOutput = ""
    @State private var ngExamples = ""

    var body: some View {
        NavigationStack {
            Form {
                // 基本情報
                Section {
                    TextField("タイトル", text: $title)

                    // カテゴリ選択
                    Button(action: { showCategoryPicker = true }) {
                        HStack {
                            Text("カテゴリ")
                            Spacer()
                            if let category = selectedCategory {
                                HStack(spacing: 4) {
                                    Image(systemName: category.icon)
                                    Text(category.name)
                                }
                                .foregroundColor(.prCategoryBlue)
                            } else {
                                Text("選択してください")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .foregroundColor(.primary)

                    // タスク選択
                    Button(action: { showTaskPicker = true }) {
                        HStack {
                            Text("タスク")
                            Spacer()
                            if let task = selectedTask {
                                HStack(spacing: 4) {
                                    Image(systemName: task.icon)
                                    Text(task.name)
                                }
                                .foregroundColor(.prCategoryGreen)
                            } else {
                                Text("選択してください")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .foregroundColor(.primary)

                    // クイックカテゴリ
                    Button(action: { showQuickCategoryPicker = true }) {
                        HStack {
                            Text("Fastカテゴリ")
                            Spacer()
                            if let category = selectedQuickCategory {
                                HStack(spacing: 4) {
                                    Image(systemName: category.icon)
                                    Text(category.rawValue)
                                }
                                .foregroundColor(category.color)
                            } else {
                                Text("選択してください")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .foregroundColor(.primary)

                    // 投稿者名
                    TextField("投稿者名", text: $authorName)
                } header: {
                    Text("基本情報")
                }

                // タグ
                Section {
                    // 追加済みタグ
                    if !tags.isEmpty {
                        FlowLayout(spacing: PRSpacing.xs) {
                            ForEach(tags, id: \.self) { tag in
                                HStack(spacing: 4) {
                                    Text("#\(tag)")
                                        .font(PRTypography.labelSmall)

                                    Button(action: { tags.removeAll { $0 == tag } }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 12))
                                    }
                                }
                                .padding(.horizontal, PRSpacing.xs)
                                .padding(.vertical, 4)
                                .background(Color.prOrange.opacity(0.1))
                                .foregroundColor(.prOrange)
                                .cornerRadius(PRRadius.xs)
                            }
                        }
                    }

                    // タグ入力
                    HStack {
                        TextField("タグを追加", text: $newTag)
                            .onSubmit {
                                addTag()
                            }

                        Button(action: addTag) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.prOrange)
                        }
                        .disabled(newTag.isEmpty || tags.count >= 5)
                    }

                    // 人気タグ
                    VStack(alignment: .leading, spacing: PRSpacing.xs) {
                        Text("人気タグ")
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray60)

                        FlowLayout(spacing: PRSpacing.xs) {
                            ForEach(store.popularTags.prefix(6)) { tag in
                                Button(action: {
                                    if !tags.contains(tag.name) && tags.count < 5 {
                                        tags.append(tag.name)
                                    }
                                }) {
                                    Text("#\(tag.name)")
                                        .font(PRTypography.labelSmall)
                                        .foregroundColor(tags.contains(tag.name) ? .white : .prGray60)
                                        .padding(.horizontal, PRSpacing.xs)
                                        .padding(.vertical, 4)
                                        .background(tags.contains(tag.name) ? Color.prOrange : Color.prGray5)
                                        .cornerRadius(PRRadius.xs)
                                }
                            }
                        }
                    }
                } header: {
                    Text("タグ（最大5個）")
                }

                // 説明
                Section {
                    TextEditor(text: $promptDescription)
                        .frame(minHeight: 100)
                } header: {
                    Text("説明")
                } footer: {
                    Text("このテンプレをどんな時に使うと便利かを説明してください（10〜500文字）")
                }

                // 用途
                Section {
                    TextEditor(text: $usageDescription)
                        .frame(minHeight: 80)
                } header: {
                    Text("用途（必須）")
                } footer: {
                    Text("このプロンプトの具体的な使用場面を説明してください")
                }

                // 前提
                Section {
                    TextEditor(text: $prerequisites)
                        .frame(minHeight: 80)
                } header: {
                    Text("前提（必須）")
                } footer: {
                    Text("使用する際に必要な前提条件や準備を説明してください")
                }

                // 期待出力
                Section {
                    TextEditor(text: $expectedOutput)
                        .frame(minHeight: 80)
                } header: {
                    Text("期待出力（必須）")
                } footer: {
                    Text("このプロンプトで得られる結果の例を説明してください")
                }

                // NG例
                Section {
                    TextEditor(text: $ngExamples)
                        .frame(minHeight: 80)
                } header: {
                    Text("NG例（必須）")
                } footer: {
                    Text("避けるべき使い方や注意点を説明してください")
                }

                // プロンプト本文
                Section {
                    TextEditor(text: $promptBody)
                        .frame(minHeight: 200)
                } header: {
                    Text("プロンプト本文")
                } footer: {
                    Text("{変数名} の形式で変数を挿入できます")
                }

                // 変数プレビュー
                if !detectedVariables.isEmpty {
                    Section {
                        ForEach(detectedVariables, id: \.self) { variable in
                            HStack {
                                Image(systemName: "textformat.abc")
                                    .foregroundColor(.prOrange)
                                Text(variable)
                            }
                        }
                    } header: {
                        Text("検出された変数")
                    }
                }

                // 確認事項
                Section {
                    Toggle(isOn: $agreedToTerms) {
                        Text("利用規約に同意する")
                            .font(PRTypography.bodySmall)
                    }
                    .tint(.prOrange)

                    Toggle(isOn: $agreedToContent) {
                        Text("著作権侵害・個人情報を含まない")
                            .font(PRTypography.bodySmall)
                    }
                    .tint(.prOrange)
                } header: {
                    Text("確認事項")
                } footer: {
                    VStack(alignment: .leading, spacing: PRSpacing.xs) {
                        Text("• 投稿したテンプレは全ユーザーに公開されます")
                        Text("• 他者の著作物や個人情報を含めないでください")
                        Text("• 不適切な内容は削除される場合があります")
                    }
                    .font(PRTypography.labelSmall)
                    .foregroundColor(.prGray60)
                }
            }
            .navigationTitle("テンプレを共有")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("投稿する") {
                        publishTemplate()
                    }
                    .disabled(!isValid)
                    .foregroundColor(isValid ? .prOrange : .prGray40)
                }
            }
            .sheet(isPresented: $showCategoryPicker) {
                ShareCategoryPickerSheet(selectedCategory: $selectedCategory)
            }
            .sheet(isPresented: $showTaskPicker) {
                ShareTaskPickerSheet(selectedTask: $selectedTask)
            }
            .sheet(isPresented: $showQuickCategoryPicker) {
                QuickCategoryPickerSheet(selectedCategory: $selectedQuickCategory)
            }
            .alert("投稿しました！", isPresented: $showSuccessAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text("テンプレが「みんなのテンプレ」に公開されました")
            }
        }
    }

    // MARK: - Computed Properties
    private var detectedVariables: [String] {
        let pattern = "\\{([^}]+)\\}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(promptBody.startIndex..., in: promptBody)
        let matches = regex.matches(in: promptBody, range: range)

        var results: [String] = []
        for match in matches {
            if let range = Range(match.range(at: 1), in: promptBody) {
                let variable = String(promptBody[range])
                if !results.contains(variable) {
                    results.append(variable)
                }
            }
        }
        return results
    }

    private var isValid: Bool {
        !title.isEmpty &&
        title.count >= 3 && title.count <= 50 &&
        !promptBody.isEmpty &&
        !promptDescription.isEmpty &&
        promptDescription.count >= 10 && promptDescription.count <= 500 &&
        !usageDescription.isEmpty &&
        !prerequisites.isEmpty &&
        !expectedOutput.isEmpty &&
        !ngExamples.isEmpty &&
        selectedCategory != nil &&
        selectedTask != nil &&
        selectedQuickCategory != nil &&
        agreedToTerms &&
        agreedToContent
    }

    // MARK: - Methods
    private func addTag() {
        let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !tags.contains(trimmed) && tags.count < 5 {
            tags.append(trimmed)
            newTag = ""
        }
    }

    private func publishTemplate() {
        guard let category = selectedCategory,
              let task = selectedTask,
              let quickCategory = selectedQuickCategory else { return }

        let displayName = authorName.isEmpty ? "ユーザー" : authorName

        store.publishTemplate(
            title: title,
            body: promptBody,
            description: promptDescription,
            categoryId: category.id,
            taskId: task.id,
            tags: tags,
            authorName: displayName
        )

        store.publishQuickPrompt(
            title: title,
            description: promptDescription,
            promptText: promptBody,
            category: quickCategory,
            tags: tags,
            authorName: displayName,
            usageDescription: usageDescription,
            prerequisites: prerequisites,
            expectedOutput: expectedOutput,
            ngExamples: ngExamples
        )

        showSuccessAlert = true
    }
}

// MARK: - Share Category Picker Sheet
struct ShareCategoryPickerSheet: View {
    @EnvironmentObject var store: PromptStore
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategory: Category?

    var body: some View {
        NavigationStack {
            List(store.categories) { category in
                Button(action: {
                    selectedCategory = category
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundColor(.prOrange)
                            .frame(width: 24)
                        Text(category.name)
                            .foregroundColor(.prGray100)
                        Spacer()
                        if selectedCategory?.id == category.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.prOrange)
                        }
                    }
                }
            }
            .navigationTitle("カテゴリを選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Share Task Picker Sheet
struct ShareTaskPickerSheet: View {
    @EnvironmentObject var store: PromptStore
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTask: PromptTask?

    var body: some View {
        NavigationStack {
            List(store.tasks) { task in
                Button(action: {
                    selectedTask = task
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: task.icon)
                            .foregroundColor(.prCategoryGreen)
                            .frame(width: 24)
                        Text(task.name)
                            .foregroundColor(.prGray100)
                        Spacer()
                        if selectedTask?.id == task.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.prCategoryGreen)
                        }
                    }
                }
            }
            .navigationTitle("タスクを選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    TemplateShareView()
        .environmentObject(PromptStore())
}

// MARK: - Quick Category Picker Sheet
struct QuickCategoryPickerSheet: View {
    @Binding var selectedCategory: QuickCategory?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(QuickCategory.allCases, id: \.self) { category in
                Button(action: {
                    selectedCategory = category
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundColor(category.color)
                            .frame(width: 24)
                        Text(category.rawValue)
                            .foregroundColor(.prGray100)
                        Spacer()
                        if selectedCategory == category {
                            Image(systemName: "checkmark")
                                .foregroundColor(.prOrange)
                        }
                    }
                }
            }
            .navigationTitle("Fastカテゴリ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
    }
}
