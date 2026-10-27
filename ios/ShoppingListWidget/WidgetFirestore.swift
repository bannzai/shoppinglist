import FirebaseCore
import FirebaseFirestore
import Foundation

/// Firestore の settings を変える処理を直列にするロック。settings は app の Firestore が最初の操作を始める前にしか変えられず、
/// 始まった後に違う settings を入れると SDK が Swift から捕まえられない例外を投げるため、確認と変更の間に別の呼び出しを挟ませない。
private let widgetFirestoreSettingsLock = NSLock()

/// app の Firestore を、ローカルキャッシュをメモリだけに置く設定にして返す。
private func widgetFirestore(app: FirebaseApp) -> Firestore {
    widgetFirestoreSettingsLock.lock()
    defer { widgetFirestoreSettingsLock.unlock() }
    let firestore = Firestore.firestore(app: app)
    if !(firestore.settings.cacheSettings is MemoryCacheSettings) {
        let settings = firestore.settings
        settings.cacheSettings = MemoryCacheSettings()
        firestore.settings = settings
    }
    return firestore
}

/// app の Firestore で operation を実行し、operation の結果を返す。
///
/// Widget Extension がファイルロックを持ったまま suspend されると 0xdead10cc で落ちる。拡張の Firestore はメモリキャッシュで使い、
/// LevelDB (ロックファイルを持つ永続キャッシュ) を開かないため、操作の後に terminate してロックを手放す必要がない。
/// terminate しないことで、同じプロセスで重なって実行中の別の呼び出しの Firestore を止めない。
func withWidgetFirestore<T>(app: FirebaseApp, operation: (Firestore) async -> T) async -> T {
    await operation(widgetFirestore(app: app))
}
