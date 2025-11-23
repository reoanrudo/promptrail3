//
//  EditTemplateView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI

struct EditTemplateView: View {
    let template: MyTemplate
    @EnvironmentObject var store: PromptStore
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var promptBody: String
    @State private var description: String
    @State private var selectedCategoryId: UUID
    @State private var selectedTaskId: UUID
    @State private var tags: [String]
    @State private var variables: [TemplateVariable]
    @State private var isPublic: Bool

    @State private var showDeleteAlert = false
    @State private var showPublishSheet = false
    @State private var showCopiedAlert = false
    @State private var variableValues: [String: String] = [:]

    init(template: MyTemplate) {
        self.template = template
        _title = State(initialValue: template.title)
        _promptBody = State(initialValue: template.body)
        _description = State(initialValue: template.description)
        _selectedCategoryId = State(initialValue: template.categoryId)
        _selectedTaskId = State(initialValue: template.taskId)
        _tags = State(initialValue: template.tags)
        _variables = State(initialValue: template.variables)
        _isPublic = State(initialValue: template.isPublic)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PRSpacing.md) {
                    // タイトル
                    VStack(alignment: .leading, spacing: PRSpacing.xs) {
                        Text("タイトル")
                            .font(PRTypography.labelMedium)
                            .foregroundColor(.prGray80)

                        TextField("テンプレのタイトル", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal, PRSpacing.md)

                    // 説明
                    VStack(alignment: .leading, spacing: PRSpacing.xs) {
                        Text("説明（使い方のコツなど）")
                            .font(PRTypography.labelMedium)
                            .foregroundColor(.prGray80)

                        TextEditor(text: $description)
                            .frame(minHeight: 80)
                            .padding(PRSpacing.xs)
                            .background(Color.prGray5)
                            .cornerRadius(PRRadius.sm)
                            .overlay(
                                RoundedRectangle(cornerRadius: PRRadius.sm)
                                    .stroke(Color.prGray20, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, PRSpacing.md)

                    // カテゴリ・タスク
                    HStack(spacing: PRSpacing.sm) {
                        VStack(alignment: .leading, spacing: PRSpacing.xs) {
                            Text("カテゴリ")
                                .font(PRTypography.labelMedium)
                                .foregroundColor(.prGray80)

                            Picker("カテゴリ", selection: $selectedCategoryId) {
                                ForEach(store.categories) { category in
                                    Text(category.name).tag(category.id)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.horizontal, PRSpacing.sm)
                            .padding(.vertical, PRSpacing.xs)
                            .background(Color.prGray5)
                            .cornerRadius(PRRadius.sm)
                        }

                        VStack(alignment: .leading, spacing: PRSpacing.xs) {
                            Text("タスク")
                                .font(PRTypography.labelMedium)
                                .foregroundColor(.prGray80)

                            Picker("タスク", selection: $selectedTaskId) {
                                ForEach(store.tasks) { task in
                                    Text(task.name).tag(task.id)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.horizontal, PRSpacing.sm)
                            .padding(.vertical, PRSpacing.xs)
                            .background(Color.prGray5)
                            .cornerRadius(PRRadius.sm)
                        }
                    }
                    .padding(.horizontal, PRSpacing.md)

                    // 変数定義セクション
                    VStack(alignment: .leading, spacing: PRSpacing.sm) {
                        HStack {
                            Text("変数定義")
                                .font(PRTypography.headlineSmall)
                                .foregroundColor(.prGray100)

                            Spacer()

                            Button(action: addVariable) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.prOrange)
                            }
                        }

                        if variables.isEmpty {
                            Text("プロンプト本文に {変数名} を含めると、自動で変数が検出されます")
                                .font(PRTypography.labelSmall)
                                .foregroundColor(.prGray40)
                                .padding(.vertical, PRSpacing.sm)
                        } else {
                            ForEach(variables.indices, id: \.self) { index in
                                VariableDefinitionRow(
                                    variable: $variables[index],
                                    onDelete: { variables.remove(at: index) }
                                )
                            }
                        }
                    }
                    .padding(PRSpacing.md)
                    .background(Color.white)
                    .cornerRadius(PRRadius.md)
                    .padding(.horizontal, PRSpacing.md)

                    // プロンプト本文
                    VStack(alignment: .leading, spacing: PRSpacing.xs) {
                        HStack {
                            Text("プロンプト本文")
                                .font(PRTypography.headlineSmall)
                                .foregroundColor(.prGray100)

                            Spacer()

                            Button(action: syncVariables) {
                                Text("変数を同期")
                                    .font(PRTypography.labelSmall)
                                    .foregroundColor(.prOrange)
                            }
                        }

                        TextEditor(text: $promptBody)
                            .font(PRTypography.code)
                            .frame(minHeight: 200)
                            .padding(PRSpacing.sm)
                            .background(Color.prGray5)
                            .cornerRadius(PRRadius.sm)
                            .overlay(
                                RoundedRectangle(cornerRadius: PRRadius.sm)
                                    .stroke(Color.prGray20, lineWidth: 1)
                            )

                        Text("ヒント: {変数名} の形式で変数を埋め込めます")
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray40)
                    }
                    .padding(.horizontal, PRSpacing.md)

                    // タグ
                    VStack(alignment: .leading, spacing: PRSpacing.xs) {
                        Text("タグ（カンマ区切り）")
                            .font(PRTypography.labelMedium)
                            .foregroundColor(.prGray80)

                        TextField("ビジネス, メール, 文章作成", text: Binding(
                            get: { tags.joined(separator: ", ") },
                            set: { tags = $0.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) } }
                        ))
                        .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal, PRSpacing.md)

                    // 公開設定
                    if !isPublic {
                        Button(action: { showPublishSheet = true }) {
                            HStack {
                                Image(systemName: "globe")
                                    .font(.system(size: 16))
                                Text("みんなにシェアする")
                                    .font(PRTypography.bodyMedium)
                            }
                            .foregroundColor(.prCategoryBlue)
                            .frame(maxWidth: .infinity)
                            .padding(PRSpacing.md)
                            .background(Color.prCategoryBlue.opacity(0.1))
                            .cornerRadius(PRRadius.md)
                        }
                        .padding(.horizontal, PRSpacing.md)
                    } else {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.prCategoryBlue)
                            Text("公開中")
                                .font(PRTypography.bodyMedium)
                                .foregroundColor(.prCategoryBlue)
                        }
                        .padding(.horizontal, PRSpacing.md)
                    }

                    // 削除ボタン
                    Button(action: { showDeleteAlert = true }) {
                        HStack {
                            Image(systemName: "trash")
                                .font(.system(size: 16))
                            Text("このテンプレを削除")
                                .font(PRTypography.bodyMedium)
                        }
                        .foregroundColor(.prCoral)
                        .frame(maxWidth: .infinity)
                        .padding(PRSpacing.md)
                    }
                    .padding(.horizontal, PRSpacing.md)
                }
                .padding(.vertical, PRSpacing.md)
                .padding(.bottom, 80)
            }
            .background(Color.prGray5)
            .navigationTitle("テンプレを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("保存") {
                        saveTemplate()
                        dismiss()
                    }
                    .disabled(title.isEmpty || promptBody.isEmpty)
                }
            }
            .alert("テンプレを削除", isPresented: $showDeleteAlert) {
                Button("削除", role: .destructive) {
                    store.deleteMyTemplate(template.id)
                    dismiss()
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("この操作は取り消せません")
            }
            .sheet(isPresented: $showPublishSheet) {
                PublishTemplateSheet(templateId: template.id)
            }
        }
    }

    private func saveTemplate() {
        var updated = template
        updated.title = title
        updated.body = promptBody
        updated.description = description
        updated.categoryId = selectedCategoryId
        updated.taskId = selectedTaskId
        updated.tags = tags
        updated.variables = variables
        updated.isPublic = isPublic
        store.updateMyTemplate(updated)
    }

    private func addVariable() {
        let newVariable = TemplateVariable(
            variableName: "variable\(variables.count + 1)",
            label: "変数\(variables.count + 1)",
            order: variables.count
        )
        variables.append(newVariable)
    }

    private func syncVariables() {
        let pattern = "\\{([^}]+)\\}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
        let range = NSRange(promptBody.startIndex..., in: promptBody)
        let matches = regex.matches(in: promptBody, range: range)

        var extractedNames: [String] = []
        for match in matches {
            if let range = Range(match.range(at: 1), in: promptBody) {
                let variable = String(promptBody[range])
                if !extractedNames.contains(variable) {
                    extractedNames.append(variable)
                }
            }
        }

        // 既存の変数を保持しつつ、新しい変数を追加
        for (index, name) in extractedNames.enumerated() {
            if !variables.contains(where: { $0.variableName == name }) {
                let newVariable = TemplateVariable(
                    variableName: name,
                    label: name,
                    order: variables.count + index
                )
                variables.append(newVariable)
            }
        }

        // プロンプト本文に存在しない変数を削除
        variables = variables.filter { extractedNames.contains($0.variableName) }
    }
}

// MARK: - Variable Definition Row
struct VariableDefinitionRow: View {
    @Binding var variable: TemplateVariable
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PRSpacing.xs) {
            HStack {
                Text("{\(variable.variableName)}")
                    .font(PRTypography.code)
                    .foregroundColor(.prOrange)

                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.prGray40)
                }
            }

            HStack(spacing: PRSpacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ラベル")
                        .font(PRTypography.labelSmall)
                        .foregroundColor(.prGray40)
                    TextField("表示名", text: $variable.label)
                        .textFieldStyle(.roundedBorder)
                        .font(PRTypography.bodySmall)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("タイプ")
                        .font(PRTypography.labelSmall)
                        .foregroundColor(.prGray40)
                    Picker("", selection: $variable.type) {
                        ForEach(VariableType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, PRSpacing.xs)
                    .background(Color.prGray5)
                    .cornerRadius(PRRadius.xs)
                }
            }

            HStack {
                Toggle("必須", isOn: $variable.required)
                    .font(PRTypography.labelSmall)
                    .toggleStyle(.switch)
                    .tint(.prOrange)

                Spacer()
            }
        }
        .padding(PRSpacing.sm)
        .background(Color.prGray5)
        .cornerRadius(PRRadius.sm)
    }
}

// MARK: - Publish Template Sheet
struct PublishTemplateSheet: View {
    let templateId: UUID
    @EnvironmentObject var store: PromptStore
    @Environment(\.dismiss) private var dismiss

    @State private var authorName = ""
    @State private var agreedToGuidelines = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: PRSpacing.md) {
                Text("テンプレを公開すると、他のユーザーがあなたのテンプレを複製して使えるようになります。")
                    .font(PRTypography.bodySmall)
                    .foregroundColor(.prGray60)

                VStack(alignment: .leading, spacing: PRSpacing.xs) {
                    Text("表示名")
                        .font(PRTypography.labelMedium)
                        .foregroundColor(.prGray80)

                    TextField("プロンプト職人", text: $authorName)
                        .textFieldStyle(.roundedBorder)
                }

                Toggle(isOn: $agreedToGuidelines) {
                    Text("個人情報や機密情報が含まれていないことを確認しました")
                        .font(PRTypography.labelSmall)
                        .foregroundColor(.prGray80)
                }
                .toggleStyle(.switch)
                .tint(.prOrange)

                Spacer()

                Button(action: publish) {
                    Text("公開する")
                }
                .buttonStyle(PRPrimaryButtonStyle())
                .disabled(authorName.isEmpty || !agreedToGuidelines)
            }
            .padding(PRSpacing.md)
            .navigationTitle("テンプレを公開")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
    }

    private func publish() {
        store.publishMyTemplate(templateId, authorName: authorName)
        dismiss()
    }
}

#Preview {
    EditTemplateView(
        template: MyTemplate(
            title: "サンプルテンプレート",
            body: "あなたは{role}です。\n\n{task}について説明してください。",
            description: "サンプルの説明文",
            categoryId: UUID(),
            taskId: UUID(),
            variables: [
                TemplateVariable(variableName: "role", label: "役割", order: 0),
                TemplateVariable(variableName: "task", label: "タスク", order: 1)
            ]
        )
    )
    .environmentObject(PromptStore())
}
