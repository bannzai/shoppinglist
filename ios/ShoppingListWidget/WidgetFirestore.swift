import FirebaseCore
import FirebaseFirestore

/// app の Firestore で operation を実行し、operation の結果を返す。
func withWidgetFirestore<T>(app: FirebaseApp, operation: (Firestore) async -> T) async -> T {
    // Widget Extension で Firestore 操作後にファイルロックを解放する（0xdead10cc 回避）
    defer { Task { try? await Firestore.firestore(app: app).terminate() } }
    return await operation(Firestore.firestore(app: app))
}
