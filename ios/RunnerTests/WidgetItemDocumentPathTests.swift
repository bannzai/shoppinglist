import XCTest

class WidgetItemDocumentPathTests: XCTestCase {

  func testDocumentPathUsesFetchedListIDs() {
    XCTAssertEqual(
      widgetItemDocumentPath(groupID: "groupA", shoppingListID: "listA", itemID: "item1"),
      "groups/groupA/shoppingLists/listA/items/item1"
    )
  }

  func testDocumentPathRejectsInvalidIDs() {
    XCTAssertNil(widgetItemDocumentPath(groupID: "", shoppingListID: "listA", itemID: "item1"))
    XCTAssertNil(widgetItemDocumentPath(groupID: "groupA", shoppingListID: "", itemID: "item1"))
    XCTAssertNil(widgetItemDocumentPath(groupID: "groupA", shoppingListID: "listA", itemID: ""))
    XCTAssertNil(widgetItemDocumentPath(groupID: "groupB/shoppingLists/listB", shoppingListID: "listA", itemID: "item1"))
    XCTAssertNil(widgetItemDocumentPath(groupID: "groupA", shoppingListID: "listA/items/x/y", itemID: "item1"))
    XCTAssertNil(widgetItemDocumentPath(groupID: "groupA", shoppingListID: "listA", itemID: "item1/sub"))
    XCTAssertNil(widgetItemDocumentPath(groupID: "..", shoppingListID: "listA", itemID: "item1"))
  }

  func testCollectionPathRejectsInvalidIDs() {
    XCTAssertEqual(widgetItemsCollectionPath(groupID: "groupA", shoppingListID: "listA"), "groups/groupA/shoppingLists/listA/items")
    XCTAssertNil(widgetItemsCollectionPath(groupID: "", shoppingListID: ""))
    XCTAssertNil(widgetItemsCollectionPath(groupID: "a/b", shoppingListID: "listA"))
  }
}
