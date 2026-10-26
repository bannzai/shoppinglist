import FirebaseCore
import FirebaseFirestore
import XCTest

class WidgetFirestoreTests: XCTestCase {

  /// テストごとに別の名前で FirebaseApp を作る。Firestore のインスタンスとローカルキャッシュのディレクトリは app 名ごとに分かれるため、
  /// テスト間・ホストアプリの既定 app と状態を共有しない。
  private func makeFirebaseApp(name: String) -> FirebaseApp {
    // ネットワークに出ない (`source: .cache` だけを使う) ため、形式だけ満たす架空の値にしている
    let options = FirebaseOptions(googleAppID: "1:1234567890:ios:0123456789abcdef", gcmSenderID: "1234567890")
    options.projectID = "demo-widget-firestore-test"
    FirebaseApp.configure(name: name, options: options)
    return FirebaseApp.app(name: name)!
  }

  /// ウィジェットの timeline の取得とトグルの intent のように、同じプロセスで Firestore を使う呼び出しが 2 つ重なった時に、
  /// 先に終わった呼び出しの後始末が、まだ実行中の呼び出しの Firestore を止めないこと (Crashlytics issue 46cef216 の条件)
  func testOverlappingOperationsDoNotTerminateEachOther() async {
    let app = makeFirebaseApp(name: "widget-overlap-\(UUID().uuidString)")
    async let longOperation: Int = withWidgetFirestore(app: app) { firestore in
      let first = try? await firestore.collection("items").getDocuments(source: .cache)
      // 短い方の呼び出しが終わり、その後始末が走り終えるのを待つ
      try? await Task.sleep(nanoseconds: 1_000_000_000)
      let second = try? await firestore.collection("items").getDocuments(source: .cache)
      return (first?.count ?? -1) + (second?.count ?? -1)
    }
    async let shortOperation: Int = withWidgetFirestore(app: app) { firestore in
      (try? await firestore.collection("items").getDocuments(source: .cache))?.count ?? -1
    }
    let results = await [longOperation, shortOperation]
    XCTAssertEqual(results, [0, 0])
  }

  /// ウィジェット拡張の Firestore が LevelDB のローカルキャッシュを作らないこと。
  /// LevelDB を開かなければ、同じプロセスで LevelDB のロックを二重に取ること (Crashlytics issue cfc59876 の
  /// `LOCK: already held by process`) も、ロックを持ったまま suspend されること (0xdead10cc) も起きない
  func testOperationDoesNotCreateLevelDBDirectory() async throws {
    let appName = "widget-leveldb-\(UUID().uuidString)"
    let app = makeFirebaseApp(name: appName)
    let count = await withWidgetFirestore(app: app) { firestore in
      (try? await firestore.collection("items").getDocuments(source: .cache))?.count ?? -1
    }
    XCTAssertEqual(count, 0)
    let firestoreDirectory = try FileManager.default
      .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
      .appendingPathComponent("firestore")
      .appendingPathComponent(appName)
    XCTAssertFalse(FileManager.default.fileExists(atPath: firestoreDirectory.path), firestoreDirectory.path)
  }
}
