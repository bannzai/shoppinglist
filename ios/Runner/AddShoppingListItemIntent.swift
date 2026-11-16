import AppIntents
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation
import WidgetKit

/// Siri・ショートカットアプリから、アプリを開かずに買い物リストへアイテムを 1 件追加する intent。
///
/// `@AppIntent(.tool)` を付けていない理由と付けられるようになる条件は documents/app-intents.md に書いている。
@available(iOS 17.0, *)
struct AddShoppingListItemIntent: AppIntent {
    /// ショートカットアプリのアクションの一覧に出る名前。Siri が何をする intent かを理解するのにも使う。
    static var title: LocalizedStringResource = "買い物リストにアイテムを追加"
    /// ショートカットアプリのアクションの詳細に出る説明。Siri が他の intent と区別するのにも使う。
    static var description = IntentDescription("アプリを開かずに買い物リストへアイテムを1件追加し、リストを共有しているメンバーにも表示します")

    /// 追加するアイテムの名前。アプリの一覧に表示される文言になる。
    @Parameter(title: "アイテムの名前", description: "買い物リストに追加するアイテムの名前 (例: 牛乳)")
    var itemName: String

    /// 追加先の買い物リスト。nil の時はアプリで開いている買い物リストに追加する。
    @Parameter(title: "買い物リスト", description: "アイテムを追加する買い物リスト (省略するとアプリで開いている買い物リスト)")
    var shoppingList: ShoppingListEntity?

    /// ショートカットアプリの編集画面に出る、parameter を埋め込んだ 1 行の文。
    static var parameterSummary: some ParameterSummary {
        Summary("\(\.$itemName)を\(\.$shoppingList)に追加")
    }

    /// 追加先の買い物リストを返す。選べる買い物リストに追加先が無ければ nil。
    /// 選べるリストは `ShoppingListEntityQuery` が決め (無料のユーザーはアプリで開いているリストだけ)、その中からの選び方は `destinationShoppingListID` が決める。
    private func destinationShoppingList() async throws -> ShoppingListEntity? {
        let availableShoppingLists = try await ShoppingListEntityQuery().suggestedEntities()
        return availableShoppingLists.first {
            $0.id == destinationShoppingListID(
                specifiedShoppingListID: shoppingList?.id,
                currentShoppingListID: UserDefaults(suiteName: widgetAppGroupId)?.string(forKey: "widget_current_shopping_list_id"),
                availableShoppingListIDs: availableShoppingLists.map(\.id)
            )
        }
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let destinationShoppingList = try await destinationShoppingList() else {
            throw ShoppingListItemAdditionError.shoppingListNotFound
        }
        try await addShoppingListItemToFirestore(
            itemName: itemName,
            groupID: destinationShoppingList.groupID,
            shoppingListID: destinationShoppingList.id
        )
        WidgetCenter.shared.reloadAllTimelines()
        return .result(dialog: "\(itemName)を\(destinationShoppingList.name)に追加しました")
    }
}

/// Siri とショートカットアプリに、設定なしで使える操作と発話を登録する。
@available(iOS 17.0, *)
struct ShoppinglistAppShortcuts: AppShortcutsProvider {
    /// 設定なしで使える操作の一覧。発話にはアプリ名を含める必要があり、文字列の parameter (アイテムの名前) は入れられない。
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddShoppingListItemIntent(),
            phrases: [
                "\(.applicationName)にアイテムを追加",
                "\(.applicationName)に追加",
                "Add an item to \(.applicationName)",
                "Add to \(.applicationName)",
            ],
            shortTitle: "アイテムを追加",
            systemImageName: "cart.badge.plus"
        )
    }
}

/// intent 専用の FirebaseApp の名前。
private let appIntentFirebaseAppName = "app-intent"

/// intent 専用の FirebaseApp を作る処理を直列にするロック。同じ名前で 2 回 configure すると SDK が Swift から捕まえられない例外を投げるため。
private let appIntentFirebaseAppLock = NSLock()

/// intent 専用の FirebaseApp を返す。アプリの GoogleService-Info.plist を読めない時は nil。
///
/// 既定の FirebaseApp は Flutter (Dart) が永続キャッシュの Firestore で使う。同じ app の Firestore に intent から
/// メモリキャッシュの settings を入れると、どちらが先に Firestore を使い始めたかで Dart 側の設定が変わるか SDK が例外を投げるため、app を分ける。
private func appIntentFirebaseApp() -> FirebaseApp? {
    appIntentFirebaseAppLock.lock()
    defer { appIntentFirebaseAppLock.unlock() }
    if let app = FirebaseApp.app(name: appIntentFirebaseAppName) {
        return app
    }
    guard let options = FirebaseOptions.defaultOptions() else { return nil }
    FirebaseApp.configure(name: appIntentFirebaseAppName, options: options)
    return FirebaseApp.app(name: appIntentFirebaseAppName)
}

/// アプリにログイン中のユーザーとして、買い物リストの末尾にアイテムを 1 件追加して Firestore に書き込む。
///
/// 書き込まずに返す条件は `addShoppingListItem` と同じ。買い物リストの有無と末尾の order はサーバーから読むため、
/// オフラインの時は書き込みを溜めずに Firestore のエラーを投げる。
func addShoppingListItemToFirestore(itemName: String, groupID: String, shoppingListID: String) async throws {
    guard let app = appIntentFirebaseApp() else { throw ShoppingListItemAdditionError.firebaseUnavailable }
    let auth = Auth.auth(app: app)
    try auth.useUserAccessGroup(widgetKeychainAccessGroup)
    try await withWidgetFirestore(app: app) { firestore -> Result<Void, Error> in
        do {
            try await addShoppingListItem(
                userID: auth.currentUser?.uid,
                itemName: itemName,
                groupID: groupID,
                shoppingListID: shoppingListID,
                shoppingListExists: { itemsCollectionPath in
                    try await firestore.collection(itemsCollectionPath).parent?.getDocument(source: .server).exists ?? false
                },
                lastItemOrder: { itemsCollectionPath in
                    try await firestore.collection(itemsCollectionPath)
                        .order(by: "order", descending: true)
                        .limit(to: 1)
                        .getDocuments(source: .server)
                        .documents.first?.data()["order"] as? Int
                },
                newItemID: { itemsCollectionPath in
                    firestore.collection(itemsCollectionPath).document().documentID
                },
                write: { itemDocumentPath, itemDocumentData in
                    // アプリの AddShoppingListItem と同じ merge の書き込み
                    try await firestore.document(itemDocumentPath).setData(itemDocumentData, merge: true)
                }
            )
            return .success(())
        } catch {
            return .failure(error)
        }
    }.get()
}
