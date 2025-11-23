//
//  FirestoreManager.swift
//  promptrail3
//
//  Firestore データベース操作管理クラス
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class FirestoreManager: ObservableObject {
    // MARK: - Published Properties

    /// 公開テンプレート一覧
    @Published var publicTemplates: [MyTemplate] = []

    /// ローディング状態
    @Published var isLoading = false

    /// エラーメッセージ
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private let db = Firestore.firestore()
    private var publicTemplatesListener: ListenerRegistration?

    // MARK: - Collection References

    /// 公開テンプレートコレクション
    private var publicTemplatesCollection: CollectionReference {
        db.collection("templates")
    }

    /// ユーザーテンプレートコレクション
    private func userTemplatesCollection(userId: String) -> CollectionReference {
        db.collection("userTemplates").document(userId).collection("templates")
    }

    /// いいねコレクション
    private var likesCollection: CollectionReference {
        db.collection("likes")
    }

    /// 使用履歴コレクション
    private var usageCollection: CollectionReference {
        db.collection("usage")
    }

    // MARK: - Community Collections

    /// コミュニティクイックプロンプトコレクション
    private var communityQuickPromptsCollection: CollectionReference {
        db.collection("communityQuickPrompts")
    }

    /// クイックプロンプトいいねコレクション
    private var quickPromptLikesCollection: CollectionReference {
        db.collection("quickPromptLikes")
    }

    /// コミュニティワークフローコレクション
    private var communityWorkflowsCollection: CollectionReference {
        db.collection("communityWorkflows")
    }

    /// ワークフローいいねコレクション
    private var workflowLikesCollection: CollectionReference {
        db.collection("workflowLikes")
    }

    /// コミュニティ画像プロンプトコレクション
    private var communityImagePromptsCollection: CollectionReference {
        db.collection("communityImagePrompts")
    }

    /// 画像プロンプトいいねコレクション
    private var imagePromptLikesCollection: CollectionReference {
        db.collection("imagePromptLikes")
    }

    /// コミュニティテンプレートコレクション（汎用）
    private var communityTemplatesCollection: CollectionReference {
        db.collection("communityTemplates")
    }

    // MARK: - Initialization

    init() {
        setupPublicTemplatesListener()
    }

    deinit {
        publicTemplatesListener?.remove()
    }

    // MARK: - Real-time Listeners

    /// 公開テンプレートのリアルタイム監視
    private func setupPublicTemplatesListener() {
        //publicTemplatesListener = publicTemplatesCollection
        publicTemplatesListener = communityImagePromptsCollection
            .whereField("isPublic", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                Task { @MainActor in
                    if let error = error {
                        print("❌ Public templates listener error: \(error.localizedDescription)")
                        self.errorMessage = error.localizedDescription
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        print("⚠️ No documents found")
                        return
                    }

                    self.publicTemplates = documents.compactMap { doc in
                        MyTemplate.fromFirestoreData(doc.data())
                    }

                    print("✅ Loaded \(self.publicTemplates.count) public templates")
                }
            }
    }

    // MARK: - Create Operations

    /// テンプレートを保存（公開 or プライベート）
    func saveTemplate(_ template: MyTemplate, userId: String) async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            let data = template.toFirestoreData()

            // ユーザーコレクションに保存
            try await userTemplatesCollection(userId: userId)
                .document(template.id.uuidString)
                .setData(data)

            // 公開設定の場合は公開コレクションにも保存
            if template.isPublic {
                try await publicTemplatesCollection
                    .document(template.id.uuidString)
                    .setData(data)
            }

            print("✅ Template saved: \(template.title)")
        } catch {
            print("❌ Save template failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// テンプレートをフォーク（複製して自分のコレクションに保存）
    func forkTemplate(_ template: MyTemplate, userId: String) async throws -> MyTemplate {
        isLoading = true
        defer { isLoading = false }

        // 新しいテンプレートを作成
        let forkedTemplate = MyTemplate(
            id: UUID(),
            title: template.title,
            body: template.body,
            description: template.description,
            categoryId: template.categoryId,
            taskId: template.taskId,
            tags: template.tags,
            variables: template.variables,
            isPublic: false,  // フォークはプライベートとして保存
            folderId: template.folderId,
            originalTemplateId: template.id,  // 元テンプレートを記録
            sampleImageUrl: template.sampleImageUrl,
            fullImageUrl: template.fullImageUrl,
            sourceType: template.sourceType,
            createdAt: Date(),
            updatedAt: Date()
        )

        do {
            let data = forkedTemplate.toFirestoreData()
            try await userTemplatesCollection(userId: userId)
                .document(forkedTemplate.id.uuidString)
                .setData(data)

            print("✅ Template forked: \(forkedTemplate.title)")

            // 使用回数をインクリメント
            try await incrementUsageCount(templateId: template.id.uuidString)

            return forkedTemplate
        } catch {
            print("❌ Fork template failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// コミュニティテンプレートを保存
    func saveCommunityTemplate(_ template: CommunityTemplate) async throws {
        let data = template.toFirestoreData()
        try await db.collection("communityTemplates")
            .document(template.id.uuidString)
            .setData(data)
        print("✅ Community template saved: \(template.title)")
    }

    // MARK: - Read Operations

    /// ユーザーのテンプレート一覧を取得
    func fetchUserTemplates(userId: String) async throws -> [MyTemplate] {
        isLoading = true
        defer { isLoading = false }

        do {
            let snapshot = try await userTemplatesCollection(userId: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()

            let templates = snapshot.documents.compactMap { doc in
                MyTemplate.fromFirestoreData(doc.data())
            }

            print("✅ Fetched \(templates.count) user templates")
            return templates
        } catch {
            print("❌ Fetch user templates failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// 公開テンプレートを検索
    func searchPublicTemplates(query: String) async throws -> [MyTemplate] {
        isLoading = true
        defer { isLoading = false }

        do {
            // Firestoreは部分一致検索が弱いので、タイトルの前方一致で検索
            let snapshot = try await publicTemplatesCollection
                .whereField("isPublic", isEqualTo: true)
                .whereField("title", isGreaterThanOrEqualTo: query)
                .whereField("title", isLessThan: query + "\u{f8ff}")
                .getDocuments()

            let templates = snapshot.documents.compactMap { doc in
                MyTemplate.fromFirestoreData(doc.data())
            }

            print("✅ Found \(templates.count) templates matching '\(query)'")
            return templates
        } catch {
            print("❌ Search templates failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// タグで公開テンプレートを検索
    func fetchTemplatesByTag(_ tag: String) async throws -> [MyTemplate] {
        isLoading = true
        defer { isLoading = false }

        do {
            let snapshot = try await publicTemplatesCollection
                .whereField("isPublic", isEqualTo: true)
                .whereField("tags", arrayContains: tag)
                .getDocuments()

            let templates = snapshot.documents.compactMap { doc in
                MyTemplate.fromFirestoreData(doc.data())
            }

            print("✅ Found \(templates.count) templates with tag '\(tag)'")
            return templates
        } catch {
            print("❌ Fetch templates by tag failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// カテゴリで公開テンプレートを検索
    func fetchTemplatesByCategory(_ categoryId: UUID) async throws -> [MyTemplate] {
        isLoading = true
        defer { isLoading = false }

        do {
            let snapshot = try await publicTemplatesCollection
                .whereField("isPublic", isEqualTo: true)
                .whereField("categoryId", isEqualTo: categoryId.uuidString)
                .getDocuments()

            let templates = snapshot.documents.compactMap { doc in
                MyTemplate.fromFirestoreData(doc.data())
            }

            print("✅ Found \(templates.count) templates in category")
            return templates
        } catch {
            print("❌ Fetch templates by category failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Update Operations

    /// テンプレートを更新
    func updateTemplate(_ template: MyTemplate, userId: String) async throws {
        isLoading = true
        defer { isLoading = false }

        var updatedTemplate = template
        updatedTemplate.updatedAt = Date()

        do {
            let data = updatedTemplate.toFirestoreData()

            // ユーザーコレクションを更新
            try await userTemplatesCollection(userId: userId)
                .document(template.id.uuidString)
                .setData(data)

            // 公開設定の場合は公開コレクションも更新
            if template.isPublic {
                try await publicTemplatesCollection
                    .document(template.id.uuidString)
                    .setData(data)
            } else {
                // 非公開に変更された場合は公開コレクションから削除
                try await publicTemplatesCollection
                    .document(template.id.uuidString)
                    .delete()
            }

            print("✅ Template updated: \(template.title)")
        } catch {
            print("❌ Update template failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Delete Operations

    /// テンプレートを削除
    func deleteTemplate(_ template: MyTemplate, userId: String) async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            // ユーザーコレクションから削除
            try await userTemplatesCollection(userId: userId)
                .document(template.id.uuidString)
                .delete()

            // 公開されていた場合は公開コレクションからも削除
            if template.isPublic {
                try await publicTemplatesCollection
                    .document(template.id.uuidString)
                    .delete()
            }

            print("✅ Template deleted: \(template.title)")
        } catch {
            print("❌ Delete template failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// コミュニティテンプレートを削除
    func deleteCommunityTemplate(templateId: String, userId: String) async throws {
        let docRef = communityTemplatesCollection.document(templateId)

        do {
            let snapshot = try await docRef.getDocument()
            guard let data = snapshot.data(),
                  let ownerId = data["userId"] as? String,
                  ownerId == userId else {
                throw NSError(
                    domain: "FirestoreManager",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "テンプレートの削除権限がありません"]
                )
            }

            try await docRef.delete()
            print("✅ Community template deleted: \(templateId)")
        } catch {
            print("❌ Delete community template failed: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Statistics Operations

    /// いいねをトグル
    func toggleLike(templateId: String, userId: String) async throws -> Bool {
        let likeId = "\(userId)_\(templateId)"
        let likeRef = likesCollection.document(likeId)

        do {
            let doc = try await likeRef.getDocument()

            if doc.exists {
                // いいね解除
                try await likeRef.delete()
                print("✅ Like removed")
                return false
            } else {
                // いいね追加
                let like: [String: Any] = [
                    "userId": userId,
                    "templateId": templateId,
                    "createdAt": Timestamp(date: Date())
                ]
                try await likeRef.setData(like)
                print("✅ Like added")
                return true
            }
        } catch {
            print("❌ Toggle like failed: \(error.localizedDescription)")
            throw error
        }
    }

    /// いいね数を取得
    func getLikeCount(templateId: String) async throws -> Int {
        do {
            let snapshot = try await likesCollection
                .whereField("templateId", isEqualTo: templateId)
                .getDocuments()

            return snapshot.documents.count
        } catch {
            print("❌ Get like count failed: \(error.localizedDescription)")
            throw error
        }
    }

    /// ユーザーがいいねしているか確認
    func isLiked(templateId: String, userId: String) async throws -> Bool {
        let likeId = "\(userId)_\(templateId)"

        do {
            let doc = try await likesCollection.document(likeId).getDocument()
            return doc.exists
        } catch {
            print("❌ Check liked status failed: \(error.localizedDescription)")
            throw error
        }
    }

    /// 使用回数をインクリメント
    func incrementUsageCount(templateId: String) async throws {
        let usageRef = usageCollection.document(templateId)

        do {
            try await usageRef.setData([
                "count": FieldValue.increment(Int64(1)),
                "lastUsedAt": Timestamp(date: Date())
            ], merge: true)

            print("✅ Usage count incremented")
        } catch {
            print("❌ Increment usage count failed: \(error.localizedDescription)")
            throw error
        }
    }

    /// 使用回数を取得
    func getUsageCount(templateId: String) async throws -> Int {
        do {
            let doc = try await usageCollection.document(templateId).getDocument()
            return doc.data()?["count"] as? Int ?? 0
        } catch {
            print("❌ Get usage count failed: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Community Quick Prompts

    /// コミュニティクイックプロンプトを保存
    func saveQuickPrompt(_ prompt: QuickPrompt, userId: String) async throws {
        isLoading = true
        defer { isLoading = false }

        var updatedPrompt = prompt
        updatedPrompt.userId = userId

        do {
            let data = updatedPrompt.toFirestoreData()
            try await communityQuickPromptsCollection
                .document(prompt.id.uuidString)
                .setData(data)

            print("✅ Quick prompt saved: \(prompt.title)")
        } catch {
            print("❌ Save quick prompt failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// コミュニティクイックプロンプトを取得
    func fetchCommunityQuickPrompts(limit: Int = 50) async throws -> [QuickPrompt] {
        isLoading = true
        defer { isLoading = false }

        do {
            let snapshot = try await communityQuickPromptsCollection
                .order(by: "likeCount", descending: true)
                .limit(to: limit)
                .getDocuments()

            let prompts = snapshot.documents.compactMap { doc in
                QuickPrompt.fromFirestoreData(doc.data())
            }

            print("✅ Fetched \(prompts.count) community quick prompts")
            return prompts
        } catch {
            print("❌ Fetch community quick prompts failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// カテゴリ別クイックプロンプトを取得
    func fetchQuickPromptsByCategory(_ category: QuickCategory) async throws -> [QuickPrompt] {
        isLoading = true
        defer { isLoading = false }

        do {
            let snapshot = try await communityQuickPromptsCollection
                .whereField("category", isEqualTo: category.rawValue)
                .order(by: "likeCount", descending: true)
                .getDocuments()

            let prompts = snapshot.documents.compactMap { doc in
                QuickPrompt.fromFirestoreData(doc.data())
            }

            print("✅ Fetched \(prompts.count) quick prompts in category \(category.rawValue)")
            return prompts
        } catch {
            print("❌ Fetch quick prompts by category failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// クイックプロンプトのいいねをトグル
    func toggleQuickPromptLike(promptId: String, userId: String) async throws -> Bool {
        let likeId = "\(userId)_\(promptId)"
        let likeRef = quickPromptLikesCollection.document(likeId)

        do {
            let doc = try await likeRef.getDocument()

            if doc.exists {
                try await likeRef.delete()
                print("✅ Quick prompt like removed")
                return false
            } else {
                let like = QuickPromptLike(userId: userId, promptId: promptId)
                try await likeRef.setData(like.toFirestoreData())
                print("✅ Quick prompt like added")
                return true
            }
        } catch {
            print("❌ Toggle quick prompt like failed: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Community Workflows

    /// コミュニティワークフローを保存
    func saveWorkflow(_ workflow: Workflow, userId: String) async throws {
        isLoading = true
        defer { isLoading = false }

        var updatedWorkflow = workflow
        updatedWorkflow.authorId = userId

        do {
            let data = updatedWorkflow.toFirestoreData()
            try await communityWorkflowsCollection
                .document(workflow.id.uuidString)
                .setData(data)

            print("✅ Workflow saved: \(workflow.title)")
        } catch {
            print("❌ Save workflow failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// コミュニティワークフローを取得
    func fetchCommunityWorkflows(limit: Int = 50) async throws -> [Workflow] {
        isLoading = true
        defer { isLoading = false }

        do {
            let snapshot = try await communityWorkflowsCollection
                .order(by: "likeCount", descending: true)
                .limit(to: limit)
                .getDocuments()

            let workflows = snapshot.documents.compactMap { doc in
                Workflow.fromFirestoreData(doc.data())
            }

            print("✅ Fetched \(workflows.count) community workflows")
            return workflows
        } catch {
            print("❌ Fetch community workflows failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// タグ別ワークフローを取得
    func fetchWorkflowsByTag(_ tag: String) async throws -> [Workflow] {
        isLoading = true
        defer { isLoading = false }

        do {
            let snapshot = try await communityWorkflowsCollection
                .whereField("tags", arrayContains: tag)
                .order(by: "likeCount", descending: true)
                .getDocuments()

            let workflows = snapshot.documents.compactMap { doc in
                Workflow.fromFirestoreData(doc.data())
            }

            print("✅ Fetched \(workflows.count) workflows with tag '\(tag)'")
            return workflows
        } catch {
            print("❌ Fetch workflows by tag failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// ワークフローのいいねをトグル
    func toggleWorkflowLike(workflowId: String, userId: String) async throws -> Bool {
        let likeId = "\(userId)_\(workflowId)"
        let likeRef = workflowLikesCollection.document(likeId)

        do {
            let doc = try await likeRef.getDocument()

            if doc.exists {
                try await likeRef.delete()
                print("✅ Workflow like removed")
                return false
            } else {
                let like = WorkflowLike(userId: userId, workflowId: workflowId)
                try await likeRef.setData(like.toFirestoreData())
                print("✅ Workflow like added")
                return true
            }
        } catch {
            print("❌ Toggle workflow like failed: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Community Image Prompts

    /// コミュニティ画像プロンプトを保存
    func saveImagePrompt(_ prompt: ImagePromptTemplate, userId: String) async throws {
        isLoading = true
        defer { isLoading = false }

        var updatedPrompt = prompt
        updatedPrompt.authorId = userId

        do {
            let data = updatedPrompt.toFirestoreData()
            try await communityImagePromptsCollection
                .document(prompt.id.uuidString)
                .setData(data)

            print("✅ Image prompt saved: \(prompt.title)")
        } catch {
            print("❌ Save image prompt failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// コミュニティ画像プロンプトを取得
    func fetchCommunityImagePrompts(limit: Int = 50) async throws -> [ImagePromptTemplate] {
        isLoading = true
        defer { isLoading = false }

        do {
            let snapshot = try await communityImagePromptsCollection
                .order(by: "likeCount", descending: true)
                .limit(to: limit)
                .getDocuments()

            let prompts = snapshot.documents.compactMap { doc in
                ImagePromptTemplate.fromFirestoreData(doc.data())
            }

            print("✅ Fetched \(prompts.count) community image prompts")
            return prompts
        } catch {
            print("❌ Fetch community image prompts failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// モデルタイプ別画像プロンプトを取得
    func fetchImagePromptsByModel(_ modelType: ImageModelType) async throws -> [ImagePromptTemplate] {
        isLoading = true
        defer { isLoading = false }

        do {
            let snapshot = try await communityImagePromptsCollection
                .whereField("modelType", isEqualTo: modelType.rawValue)
                .order(by: "likeCount", descending: true)
                .getDocuments()

            let prompts = snapshot.documents.compactMap { doc in
                ImagePromptTemplate.fromFirestoreData(doc.data())
            }

            print("✅ Fetched \(prompts.count) image prompts for model \(modelType.rawValue)")
            return prompts
        } catch {
            print("❌ Fetch image prompts by model failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// タグ別画像プロンプトを取得
    func fetchImagePromptsByTag(_ tag: String) async throws -> [ImagePromptTemplate] {
        isLoading = true
        defer { isLoading = false }

        do {
            let snapshot = try await communityImagePromptsCollection
                .whereField("tags", arrayContains: tag)
                .order(by: "likeCount", descending: true)
                .getDocuments()

            let prompts = snapshot.documents.compactMap { doc in
                ImagePromptTemplate.fromFirestoreData(doc.data())
            }

            print("✅ Fetched \(prompts.count) image prompts with tag '\(tag)'")
            return prompts
        } catch {
            print("❌ Fetch image prompts by tag failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// 画像プロンプトのいいねをトグル
    func toggleImagePromptLike(promptId: String, userId: String) async throws -> Bool {
        let likeId = "\(userId)_\(promptId)"
        let likeRef = imagePromptLikesCollection.document(likeId)

        do {
            let doc = try await likeRef.getDocument()

            if doc.exists {
                try await likeRef.delete()
                print("✅ Image prompt like removed")
                return false
            } else {
                let like = ImagePromptLike(userId: userId, templateId: promptId)
                try await likeRef.setData(like.toFirestoreData())
                print("✅ Image prompt like added")
                return true
            }
        } catch {
            print("❌ Toggle image prompt like failed: \(error.localizedDescription)")
            throw error
        }
    }
}
