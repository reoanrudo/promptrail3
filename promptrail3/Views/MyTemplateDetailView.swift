//
//  MyTemplateDetailView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/21.
//

import SwiftUI

struct MyTemplateDetailView: View {
    let template: MyTemplate
    @EnvironmentObject var store: PromptStore
    @Environment(\.dismiss) private var dismiss
    @State private var showCopiedAlert = false
    @State private var showEditView = false
    @State private var showExecutionView = false
    @State private var variableValues: [String: String] = [:]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PRSpacing.lg) {
                if let imageURL = previewImageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.prGray10)
                                .frame(height: 220)
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, minHeight: 220)
                                .clipped()
                        case .failure:
                            Rectangle()
                                .fill(Color.prGray10)
                                .frame(height: 220)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.prGray40)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: PRRadius.lg))
                    .padding(.horizontal, PRSpacing.md)
                }

                // ヘッダー
                VStack(alignment: .leading, spacing: PRSpacing.sm) {
                    // カテゴリバッジ
                    if let category = store.category(for: template.categoryId) {
                        HStack(spacing: PRSpacing.xs) {
                            Image(systemName: category.icon)
                                .font(.system(size: 14))
                            Text(category.name)
                                .font(PRTypography.labelMedium)
                        }
                        .foregroundColor(.prCategoryBlue)
                        .padding(.horizontal, PRSpacing.sm)
                        .padding(.vertical, PRSpacing.xs)
                        .background(Color.prCategoryBlue.opacity(0.1))
                        .cornerRadius(PRRadius.pill)
                    }

                    // タイトル
                    Text(template.title)
                        .font(PRTypography.headlineLarge)
                        .foregroundColor(.prGray100)

                    // 説明
                    if !template.description.isEmpty {
                        Text(template.description)
                            .font(PRTypography.bodyMedium)
                            .foregroundColor(.prGray60)
                    }

                    // タグ
                    if !template.tags.isEmpty {
                        FlowLayout(spacing: PRSpacing.xs) {
                            ForEach(template.tags, id: \.self) { tag in
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
                }
                .padding(.horizontal, PRSpacing.md)

                // アクションボタン
                HStack(spacing: PRSpacing.sm) {
                    // ワークフローの場合は実行ボタン、それ以外はコピーボタン
                    if isWorkflow, let workflow = sourceWorkflow {
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
                    } else {
                        Button(action: copyToClipboard) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("コピー")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PRPrimaryButtonStyle())
                    }

                    // 編集ボタン
                    Button(action: {
                        showEditView = true
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16))
                            .foregroundColor(.prGray60)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: 48)
                    .background(Color.white)
                    .cornerRadius(PRRadius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: PRRadius.md)
                            .stroke(Color.prGray20, lineWidth: 1)
                    )
                }
                .padding(.horizontal, PRSpacing.md)

                // ワークフローのステップ一覧
                if isWorkflow, let workflow = sourceWorkflow {
                    VStack(alignment: .leading, spacing: PRSpacing.sm) {
                        HStack {
                            Image(systemName: "list.bullet.rectangle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.prCategoryBlue)

                            Text("ステップ")
                                .font(PRTypography.headlineSmall)
                                .foregroundColor(.prGray100)

                            Spacer()

                            Text("\(workflow.steps.count)")
                                .font(PRTypography.labelSmall)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.prCategoryBlue)
                                .cornerRadius(PRRadius.xs)
                        }

                        VStack(spacing: 0) {
                            ForEach(Array(workflow.steps.enumerated()), id: \.element.id) { index, step in
                                WorkflowStepPreview(step: step, stepNumber: index + 1, isLast: index == workflow.steps.count - 1)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(PRRadius.md)
                    }
                    .padding(PRSpacing.md)
                    .background(Color.prGray5)
                    .cornerRadius(PRRadius.md)
                    .padding(.horizontal, PRSpacing.md)
                }

                // 変数入力フィールド
                if !template.variables.isEmpty {
                    VStack(alignment: .leading, spacing: PRSpacing.md) {
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.prOrange)

                            Text("変数")
                                .font(PRTypography.headlineSmall)
                                .foregroundColor(.prGray100)

                            Spacer()

                            Text("\(template.variables.count)")
                                .font(PRTypography.labelSmall)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.prOrange)
                                .cornerRadius(PRRadius.xs)
                        }

                        ForEach(template.variables, id: \.variableName) { variable in
                            MyTemplateVariableInputField(
                                variable: variable,
                                value: binding(for: variable.variableName)
                            )
                        }
                    }
                    .padding(PRSpacing.md)
                    .background(Color.prGray5)
                    .cornerRadius(PRRadius.md)
                    .padding(.horizontal, PRSpacing.md)
                }

                // プロンプトプレビュー（ワークフロー以外の場合のみ表示）
                if !isWorkflow {
                    VStack(alignment: .leading, spacing: PRSpacing.sm) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.prCategoryBlue)

                            Text("プロンプト")
                                .font(PRTypography.headlineSmall)
                                .foregroundColor(.prGray100)

                            Spacer()
                        }

                        // 変数があるときはハイライト表示
                        if !template.variables.isEmpty {
                            previewTextWithHighlights
                        } else {
                            Text(template.body)
                                .font(PRTypography.code)
                                .foregroundColor(.prGray80)
                                .textSelection(.enabled)
                                .padding(PRSpacing.md)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(PRRadius.sm)
                                .overlay(
                                    RoundedRectangle(cornerRadius: PRRadius.sm)
                                        .stroke(Color.prGray20, lineWidth: 1)
                                )
                        }
                    }
                    .padding(PRSpacing.md)
                    .background(Color.prGray5)
                    .cornerRadius(PRRadius.md)
                    .padding(.horizontal, PRSpacing.md)
                }
            }
            .padding(.vertical, PRSpacing.md)
            .padding(.bottom, 80)
        }
        .background(Color.prBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showEditView) {
            EditTemplateView(template: template)
        }
        .fullScreenCover(isPresented: $showExecutionView) {
            if let workflow = sourceWorkflow {
                WorkflowExecutionView(workflow: workflow)
            }
        }
        .alert("コピーしました", isPresented: $showCopiedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("ChatGPTやClaudeに貼り付けて使用してください")
        }
        .onAppear {
            initializeVariableValues()
        }
    }

    private func initializeVariableValues() {
        for variable in template.variables {
            if let defaultValue = variable.defaultValue, !defaultValue.isEmpty {
                variableValues[variable.variableName] = defaultValue
            } else {
                variableValues[variable.variableName] = ""
            }
        }
    }

    private var filledPrompt: String {
        var text = template.body
        for (key, value) in variableValues {
            text = text.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return text
    }

    // 変数をハイライト表示するView
    private var previewTextWithHighlights: some View {
        let attributedText = createHighlightedText()

        return Text(attributedText)
            .font(PRTypography.code)
            .textSelection(.enabled)
            .padding(PRSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(PRRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: PRRadius.sm)
                    .stroke(Color.prGray20, lineWidth: 1)
            )
    }

    // AttributedStringを生成
    private func createHighlightedText() -> AttributedString {
        let text = filledPrompt
        let pattern = "\\{([^}]+)\\}"

        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return AttributedString(text)
        }

        let nsString = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))

        let attributedString = NSMutableAttributedString(string: text)

        // 残りの変数を赤色でマーク
        for match in matches {
            attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: match.range)
        }

        return AttributedString(attributedString)
    }

    private func binding(for variable: String) -> Binding<String> {
        Binding(
            get: { variableValues[variable] ?? "" },
            set: { variableValues[variable] = $0 }
        )
    }

    private func copyToClipboard() {
        UIPasteboard.general.string = filledPrompt
        showCopiedAlert = true
    }

    private var previewImageURL: URL? {
        if let source = sourceImageTemplate {
            return URL(string: source.fullImageUrl)
        }

        let urlString = template.fullImageUrl?.isEmpty == false ? template.fullImageUrl :
            (template.sampleImageUrl?.isEmpty == false ? template.sampleImageUrl : nil)
        guard let urlString, let url = URL(string: urlString) else {
            return nil
        }
        return url
    }

    private var sourceImageTemplate: ImagePromptTemplate? {
        guard let sourceId = template.originalTemplateId else { return nil }
        return store.imagePromptTemplates.first(where: { $0.id == sourceId })
    }

    private var isWorkflow: Bool {
        store.getTemplateSourceType(template) == .workflow
    }

    private var sourceWorkflow: Workflow? {
        guard let sourceId = template.originalTemplateId else { return nil }
        return store.workflows.first(where: { $0.id == sourceId })
    }
}

// MARK: - My Template Variable Input Field
private struct MyTemplateVariableInputField: View {
    let variable: TemplateVariable
    @Binding var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: PRSpacing.xs) {
            HStack {
                Text(variable.label)
                    .font(PRTypography.labelMedium)
                    .foregroundColor(.prGray80)

                if variable.required {
                    Text("*")
                        .font(PRTypography.labelMedium)
                        .foregroundColor(.prCoral)
                }
            }

            if let description = variable.description, !description.isEmpty {
                Text(description)
                    .font(PRTypography.labelSmall)
                    .foregroundColor(.prGray40)
            }

            switch variable.type {
            case .text:
                textField()
            case .number:
                textField(keyboard: .numberPad)
            case .select:
                pickerField
            case .textarea:
                TextEditor(text: $value)
                    .frame(minHeight: 80)
                    .padding(PRSpacing.xs)
                    .background(Color.white)
                    .cornerRadius(PRRadius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: PRRadius.sm)
                            .stroke(borderColor, lineWidth: 1.2)
                    )
            }
        }
        .padding(.vertical, PRSpacing.xs)
    }

    private var borderColor: Color {
        value.isEmpty ? Color.prGray20 : .prOrange
    }

    private var placeholderText: String {
        variable.placeholder ?? variable.label
    }

    @ViewBuilder
    private func textField(keyboard: UIKeyboardType = .default) -> some View {
        TextField(placeholderText, text: $value)
            .font(PRTypography.bodyMedium)
            .padding(PRSpacing.sm)
            .background(Color.white)
            .cornerRadius(PRRadius.sm)
            .keyboardType(keyboard)
            .overlay(
                RoundedRectangle(cornerRadius: PRRadius.sm)
                    .stroke(borderColor, lineWidth: 1.2)
            )
    }

    @ViewBuilder
    private var pickerField: some View {
        if let options = variable.options {
            Menu {
                Picker(selection: $value, label: EmptyView()) {
                    Text("選択してください").tag("")
                    ForEach(options, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.inline)
            } label: {
                HStack {
                    Text(value.isEmpty ? "選択してください" : value)
                        .font(PRTypography.bodyMedium)
                        .foregroundColor(value.isEmpty ? .prGray40 : .prGray100)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.prGray40)
                }
                .padding(PRSpacing.sm)
                .background(Color.white)
                .cornerRadius(PRRadius.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: PRRadius.sm)
                        .stroke(borderColor, lineWidth: 1.2)
                )
            }
        } else {
            textField()
        }
    }
}

#Preview {
    NavigationStack {
        MyTemplateDetailView(
            template: MyTemplate(
                title: "サンプルテンプレート",
                body: "こんにちは、{name}さん。{topic}について教えてください。",
                description: "テスト用のテンプレートです",
                categoryId: UUID(),
                taskId: UUID(),
                tags: ["テスト", "サンプル"],
                variables: [
                    TemplateVariable(variableName: "name", label: "名前", placeholder: "名前を入力"),
                    TemplateVariable(variableName: "topic", label: "トピック", placeholder: "トピックを入力")
                ],
                isPublic: false
            )
        )
        .environmentObject(PromptStore())
    }
}
