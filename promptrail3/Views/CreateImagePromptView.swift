//
//  CreateImagePromptView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI
import PhotosUI
import UIKit

struct CreateImagePromptView: View {
    @EnvironmentObject var store: PromptStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var promptText = ""
    @State private var selectedModelType: ImageModelType = .midjourney
    @State private var selectedAspectRatio: AspectRatio = .square
    @State private var tagInput = ""
    @State private var tags: [String] = []
    @State private var authorName = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var selectedImageData: Data?
    @State private var isUploadingImage = false
    @State private var uploadErrorMessage: String?

    private let storageManager = StorageManager()
    private let recommendedColumns = [
        GridItem(.adaptive(minimum: 90), spacing: PRSpacing.xs, alignment: .leading)
    ]

    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                imageSettingsSection
                imagePickerSection
                tagsSection
            }
            .navigationTitle("画像プロンプトを投稿")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await publishImagePrompt() }
                    } label: {
                        if isUploadingImage {
                            ProgressView()
                        } else {
                            Text("投稿")
                        }
                    }
                    .disabled(!isValid || isUploadingImage)
                }
            }
        }
        .onChange(of: selectedPhotoItem) { newValue in
            loadImage(from: newValue)
        }
        .alert(
            "アップロードに失敗しました",
            isPresented: uploadErrorBinding,
            presenting: uploadErrorMessage
        ) { _ in
            Button("OK", role: .cancel) {
                uploadErrorMessage = nil
            }
        } message: { message in
            Text(message)
        }
    }

    private var basicInfoSection: some View {
        Section("基本情報") {
            TextField("タイトル", text: $title)

            VStack(alignment: .leading, spacing: PRSpacing.xs) {
                Text("プロンプト")
                    .font(PRTypography.labelSmall)
                    .foregroundColor(.prGray60)

                TextEditor(text: $promptText)
                    .frame(minHeight: 100)
                    .font(PRTypography.bodySmall)
            }

            TextField("投稿者名", text: $authorName)
        }
    }

    private var imageSettingsSection: some View {
        Section("画像設定") {
            Picker("AIモデル", selection: $selectedModelType) {
                ForEach(ImageModelType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }

            Picker("アスペクト比", selection: $selectedAspectRatio) {
                ForEach(AspectRatio.allCases, id: \.self) { ratio in
                    Text(ratio.displayName).tag(ratio)
                }
            }
        }
    }

    private var imagePickerSection: some View {
        Section("画像") {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                HStack {
                    Image(systemName: "photo.fill.on.rectangle.fill")
                    Text(selectedImage == nil ? "iPhoneの写真から選択" : "別の写真を選ぶ")
                }
            }

            if let image = selectedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 220)
                        .cornerRadius(PRRadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: PRRadius.md)
                                .stroke(Color.prGray20, lineWidth: 1)
                        )

                    Button {
                        self.selectedImage = nil
                        selectedImageData = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                            .padding(8)
                    }
                }
            } else {
                Text("※URL入力は不要です。写真アプリから直接選べます。")
                    .font(PRTypography.labelSmall)
                    .foregroundColor(.prGray40)
                    .padding(.vertical, PRSpacing.xs)
            }
        }
    }

    private var tagsSection: some View {
        Section("タグ") {
            HStack {
                TextField("タグを追加", text: $tagInput)
                    .onSubmit { addTag() }

                Button(action: addTag) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.prOrange)
                }
                .disabled(tagInput.isEmpty)
            }

            if !tags.isEmpty {
                FlowLayout(spacing: PRSpacing.xs) {
                    ForEach(tags, id: \.self) { tag in
                        TagChip(tag: tag) { removeTag(tag) }
                    }
                }
            }

            VStack(alignment: .leading, spacing: PRSpacing.xs) {
                Text("推奨タグ")
                    .font(PRTypography.labelSmall)
                    .foregroundColor(.prGray40)

                LazyVGrid(columns: recommendedColumns, alignment: .leading, spacing: PRSpacing.xs) {
                    ForEach(ImageTag.allCases, id: \.self) { tag in
                        RecommendedTagButton(
                            title: tag.rawValue,
                            isSelected: tags.contains(tag.rawValue)
                        ) {
                            toggleRecommendedTag(tag.rawValue)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var isValid: Bool {
        !title.isEmpty &&
        !promptText.isEmpty &&
        !authorName.isEmpty &&
        selectedImageData != nil
    }

    private struct TagChip: View {
        let tag: String
        let onRemove: () -> Void

        var body: some View {
            HStack(spacing: 4) {
                Text(tag)
                    .font(PRTypography.labelSmall)

                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                }
            }
            .foregroundColor(.prCategoryBlue)
            .padding(.horizontal, PRSpacing.xs)
            .padding(.vertical, 4)
            .background(Color.prCategoryBlue.opacity(0.1))
            .cornerRadius(PRRadius.xs)
        }
    }

    private struct RecommendedTagButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(PRTypography.labelSmall)
                    .foregroundColor(isSelected ? .white : .prGray60)
                    .padding(.horizontal, PRSpacing.xs)
                    .padding(.vertical, 4)
                    .background(isSelected ? Color.prOrange : Color.prGray10)
                    .cornerRadius(PRRadius.xs)
            }
        }
    }

    private func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !tags.contains(trimmed) {
            tags.append(trimmed)
            tagInput = ""
        }
    }

    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    private func toggleRecommendedTag(_ tag: String) {
        if let index = tags.firstIndex(of: tag) {
            tags.remove(at: index)
        } else {
            tags.append(tag)
        }
    }

    private func loadImage(from item: PhotosPickerItem?) {
        guard let item else { return }

        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data),
                   let compressedData = image.jpegData(compressionQuality: 0.85) {
                    await MainActor.run {
                        selectedImage = image
                        selectedImageData = compressedData
                    }
                } else {
                    await MainActor.run {
                        uploadErrorMessage = "画像の読み込みに失敗しました"
                    }
                }
            } catch {
                await MainActor.run {
                    uploadErrorMessage = error.localizedDescription
                }
            }
        }
    }

    private func publishImagePrompt() async {
        guard let imageData = selectedImageData else { return }
        isUploadingImage = true

        do {
            let imageUrl = try await storageManager.uploadImage(data: imageData, folder: "imagePrompts")

            let template = ImagePromptTemplate(
                title: title,
                promptText: promptText,
                tags: tags,
                sampleImageUrl: imageUrl,
                fullImageUrl: imageUrl,
                modelType: selectedModelType,
                aspectRatio: selectedAspectRatio,
                authorId: store.currentUserIdString,
                authorName: authorName.isEmpty ? "あなた" : authorName
            )

            try await store.saveImagePromptToCommunity(template)

            await MainActor.run {
                isUploadingImage = false
                dismiss()
            }
        } catch {
            await MainActor.run {
                uploadErrorMessage = error.localizedDescription
                isUploadingImage = false
            }
        }
    }

    private var uploadErrorBinding: Binding<Bool> {
        Binding(
            get: { uploadErrorMessage != nil },
            set: { if !$0 { uploadErrorMessage = nil } }
        )
    }
}

#Preview {
    CreateImagePromptView()
        .environmentObject(PromptStore())
}
