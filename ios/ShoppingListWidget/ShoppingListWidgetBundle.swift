import FirebaseCore
import FirebaseAuth
import SwiftUI
import WidgetKit

@main
struct ShoppingListWidgetBundle: WidgetBundle {
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        do {
            try Auth.auth().useUserAccessGroup(widgetKeychainAccessGroup)
        } catch {
            print("[ShoppingListWidgetBundle] useUserAccessGroup failed: \(error)")
        }
    }

    var body: some Widget {
        ShoppingListWidget()
    }
}
