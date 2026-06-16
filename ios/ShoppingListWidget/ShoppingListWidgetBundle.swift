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
            // dev(Debug)ビルドは本番と Keychain group を分離する(Issue #410 / ADR 0030)。
            // Dart の app_identity.keychainAccessGroup / entitlements の
            // $(AppIdentifierPrefix)$(KEYCHAIN_ACCESS_GROUP) と一致させる。
            #if DEBUG
            try Auth.auth().useUserAccessGroup("TQPN82UBBY.com.bannzai.shoppinglist.dev")
            #else
            try Auth.auth().useUserAccessGroup("TQPN82UBBY.com.bannzai.shoppinglist")
            #endif
        } catch {
            print("[ShoppingListWidgetBundle] useUserAccessGroup failed: \(error)")
        }
    }

    var body: some Widget {
        ShoppingListWidget()
    }
}
