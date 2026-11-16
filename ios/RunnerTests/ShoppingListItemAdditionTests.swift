import FirebaseFirestore
import XCTest

/// Siri・ショートカットからのアイテムの追加 (`addShoppingListItem`) が、アプリ (Dart) と同じパス・同じ形の文書を書き、
/// 書けない条件では書き込まずに理由を返すことのテスト
class ShoppingListItemAdditionTests: XCTestCase {

  /// アプリが新しいアイテムを追加する時のパスと文書の形。Dart 側のテスト
  /// (test/provider/add_shopping_list_item_document_test.dart) も同じファイルと照合する
  private func loadFixture() throws -> [String: Any] {
    try XCTUnwrap(
      JSONSerialization.jsonObject(
        with: Data(
          contentsOf: URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("../../test/fixtures/new_shopping_list_item_document.json")
        )
      ) as? [String: Any]
    )
  }

  /// Firestore に渡す値を、fixture の JSON で表せる形にして返す。
  /// 時刻は実行のたびに変わるため、クライアントの時刻かサーバーの時刻かの区別だけを残す
  private func comparableFirestoreValue(value: Any) -> Any {
    switch value {
    case is Timestamp: return "<client timestamp>"
    case is FieldValue: return "<server timestamp>"
    default: return value
    }
  }

  /// `addShoppingListItem` を呼び、書き込まれた (文書パス, 文書) の一覧と、投げられたエラーを返す
  private func runAddShoppingListItem(
    userID: String?,
    itemName: String,
    groupID: String,
    shoppingListID: String,
    shoppingListExists: Bool,
    lastItemOrder: Int?,
    newItemID: String
  ) async -> (writes: [(path: String, data: [String: Any])], error: Error?) {
    var writes: [(path: String, data: [String: Any])] = []
    do {
      try await addShoppingListItem(
        userID: userID,
        itemName: itemName,
        groupID: groupID,
        shoppingListID: shoppingListID,
        shoppingListExists: { _ in shoppingListExists },
        lastItemOrder: { _ in lastItemOrder },
        newItemID: { _ in newItemID },
        write: { path, data in writes.append((path: path, data: data)) }
      )
      return (writes, nil)
    } catch {
      return (writes, error)
    }
  }

  /// 書き込む文書のパスとフィールドが、アプリが作るアイテム (fixture) と同じであること
  func testWritesSamePathAndFieldsAsApp() async throws {
    let fixture = try loadFixture()
    let document = try XCTUnwrap(fixture["document"] as? [String: Any])
    let itemID = try XCTUnwrap(document["id"] as? String)
    let result = await runAddShoppingListItem(
      userID: document["userID"] as? String,
      itemName: try XCTUnwrap(document["message"] as? String),
      groupID: try XCTUnwrap(document["groupID"] as? String),
      shoppingListID: try XCTUnwrap(document["shoppingListID"] as? String),
      shoppingListExists: true,
      lastItemOrder: try XCTUnwrap(document["order"] as? Int) - 1,
      newItemID: itemID
    )

    XCTAssertNil(result.error)
    XCTAssertEqual(result.writes.map(\.path), ["\(try XCTUnwrap(fixture["collectionPath"] as? String))/\(itemID)"])
    XCTAssertEqual(
      try XCTUnwrap(result.writes.first).data.mapValues { comparableFirestoreValue(value: $0) } as NSDictionary,
      document as NSDictionary
    )
  }

  /// アイテムが 1 件も無いリストでは order が 0 になること (アプリの nextOrder と同じ)
  func testOrderIsZeroWhenListHasNoItems() async {
    let result = await runAddShoppingListItem(
      userID: "user", itemName: "牛乳", groupID: "group", shoppingListID: "list",
      shoppingListExists: true, lastItemOrder: nil, newItemID: "item"
    )
    XCTAssertEqual(result.writes.first?.data["order"] as? Int, 0)
  }

  /// 名前の前後の空白と改行を落として書き込むこと
  func testTrimsItemName() async {
    let result = await runAddShoppingListItem(
      userID: "user", itemName: "  牛乳\n", groupID: "group", shoppingListID: "list",
      shoppingListExists: true, lastItemOrder: 0, newItemID: "item"
    )
    XCTAssertEqual(result.writes.first?.data["message"] as? String, "牛乳")
  }

  /// 未ログインの時は書き込まずに notSignedIn を返すこと
  func testDoesNotWriteWhenNotSignedIn() async {
    let result = await runAddShoppingListItem(
      userID: nil, itemName: "牛乳", groupID: "group", shoppingListID: "list",
      shoppingListExists: true, lastItemOrder: 0, newItemID: "item"
    )
    XCTAssertEqual(result.error as? ShoppingListItemAdditionError, .notSignedIn)
    XCTAssertEqual(result.writes.count, 0)
  }

  /// 追加先の買い物リストがサーバーに無い時は書き込まずに shoppingListNotFound を返すこと
  func testDoesNotWriteWhenShoppingListDoesNotExist() async {
    let result = await runAddShoppingListItem(
      userID: "user", itemName: "牛乳", groupID: "group", shoppingListID: "list",
      shoppingListExists: false, lastItemOrder: 0, newItemID: "item"
    )
    XCTAssertEqual(result.error as? ShoppingListItemAdditionError, .shoppingListNotFound)
    XCTAssertEqual(result.writes.count, 0)
  }

  /// リストの ID が Firestore のパスに使えない時 (空・別のパスを指す) は書き込まずに shoppingListNotFound を返すこと
  func testDoesNotWriteWhenShoppingListIDIsInvalid() async {
    for shoppingListID in ["", "a/b"] {
      let result = await runAddShoppingListItem(
        userID: "user", itemName: "牛乳", groupID: "group", shoppingListID: shoppingListID,
        shoppingListExists: true, lastItemOrder: 0, newItemID: "item"
      )
      XCTAssertEqual(result.error as? ShoppingListItemAdditionError, .shoppingListNotFound, shoppingListID)
      XCTAssertEqual(result.writes.count, 0, shoppingListID)
    }
  }

  /// グループの ID が Firestore のパスに使えない時 (空・別のパスを指す) は書き込まずに shoppingListNotFound を返すこと
  func testDoesNotWriteWhenGroupIDIsInvalid() async {
    for groupID in ["", "a/b"] {
      let result = await runAddShoppingListItem(
        userID: "user", itemName: "牛乳", groupID: groupID, shoppingListID: "list",
        shoppingListExists: true, lastItemOrder: 0, newItemID: "item"
      )
      XCTAssertEqual(result.error as? ShoppingListItemAdditionError, .shoppingListNotFound, groupID)
      XCTAssertEqual(result.writes.count, 0, groupID)
    }
  }

  /// 追加先を指定した時は、選べる買い物リストにある時だけその買い物リストになること
  func testDestinationIsSpecifiedShoppingListOnlyWhenAvailable() {
    XCTAssertEqual(
      destinationShoppingListID(
        specifiedShoppingListID: "specified", currentShoppingListID: "current",
        availableShoppingListIDs: ["first", "current", "specified"]
      ),
      "specified"
    )
    XCTAssertNil(
      destinationShoppingListID(
        specifiedShoppingListID: "specified", currentShoppingListID: "current",
        availableShoppingListIDs: ["first", "current"]
      )
    )
  }

  /// 追加先を省略した時は、アプリで開いている買い物リストになること
  func testDestinationIsCurrentShoppingListWhenNotSpecified() {
    XCTAssertEqual(
      destinationShoppingListID(
        specifiedShoppingListID: nil, currentShoppingListID: "current",
        availableShoppingListIDs: ["first", "current"]
      ),
      "current"
    )
  }

  /// 追加先を省略し、アプリで開いている買い物リストが選べない・無い時は、選べる買い物リストの先頭になること
  func testDestinationIsFirstAvailableShoppingListWhenCurrentIsNotAvailable() {
    for currentShoppingListID in ["deleted", nil] {
      XCTAssertEqual(
        destinationShoppingListID(
          specifiedShoppingListID: nil, currentShoppingListID: currentShoppingListID,
          availableShoppingListIDs: ["first", "second"]
        ),
        "first"
      )
    }
  }

  /// 選べる買い物リストが 1 つも無い時は、追加先が無いこと
  func testDestinationIsNilWhenNoShoppingListIsAvailable() {
    XCTAssertNil(
      destinationShoppingListID(
        specifiedShoppingListID: nil, currentShoppingListID: "current", availableShoppingListIDs: []
      )
    )
    XCTAssertNil(
      destinationShoppingListID(
        specifiedShoppingListID: "specified", currentShoppingListID: nil, availableShoppingListIDs: []
      )
    )
  }

  /// 名前が空・空白だけの時は書き込まずに emptyItemName を返すこと
  func testDoesNotWriteWhenItemNameIsBlank() async {
    for itemName in ["", " \n"] {
      let result = await runAddShoppingListItem(
        userID: "user", itemName: itemName, groupID: "group", shoppingListID: "list",
        shoppingListExists: true, lastItemOrder: 0, newItemID: "item"
      )
      XCTAssertEqual(result.error as? ShoppingListItemAdditionError, .emptyItemName)
      XCTAssertEqual(result.writes.count, 0)
    }
  }
}
