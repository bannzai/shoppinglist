import FirebaseCore
import FirebaseFirestore
import XCTest

/// ウィジェット拡張の `withWidgetFirestore` が、同じプロセスで重なる呼び出しと LevelDB のロックで落ちないことのテスト
class WidgetFirestoreTests: XCTestCase {

  /// テストごとに別の名前で FirebaseApp を作る。Firestore のインスタンスとローカルキャッシュのディレクトリは app 名ごとに分かれるため、
  /// テスト間・ホストアプリの既定 app と状態を共有しない。
  private func makeFirebaseApp(name: String) -> FirebaseApp {
    // ネットワークに出ない (`source: .cache` だけを使う) ため、形式だけ満たす架空の値にしている。
    // テストのホストアプリ (Runner) が FirebaseAuth・FirebaseInstallations をリンクしており、configure の時点で両者が
    // API キーの有無と形式 (`A` で始まる 39 文字。FIRInstallations の validateAPIKey) を検査して落ちるため、API キーも入れる
    let options = FirebaseOptions(googleAppID: "1:1234567890:ios:0123456789abcdef", gcmSenderID: "1234567890")
    options.apiKey = "A" + String(repeating: "0", count: 38)
    options.projectID = "demo-widget-firestore-test"
    FirebaseApp.configure(name: name, options: options)
    return FirebaseApp.app(name: name)!
  }

  /// firestore の items コレクションをローカルキャッシュだけから読んだ件数を返す。読み取りに失敗した時は nil を返し、
  /// 期待値の件数 0 と取り違えずにテストを失敗させる
  private func cachedItemCount(firestore: Firestore) async -> Int? {
    (try? await firestore.collection("items").getDocuments(source: .cache))?.count
  }

  /// ウィジェットの timeline の取得とトグルの intent のように、同じプロセスで Firestore を使う呼び出しが 2 つ重なった時に、
  /// 先に終わった呼び出しの後始末が、まだ実行中の呼び出しの Firestore を止めないこと (Crashlytics issue 46cef216 の条件)
  func testOverlappingOperationsDoNotTerminateEachOther() async {
    let app = makeFirebaseApp(name: "widget-overlap-\(UUID().uuidString)")
    async let longOperation: [Int?] = withWidgetFirestore(app: app) { firestore in
      let first = await cachedItemCount(firestore: firestore)
      // 短い方の呼び出しが終わり、その後始末が走り終えるのを待つ。後始末はテストから完了を待てない Task のため時間で待つ。
      // 1 秒は、修正前のコード (後始末で terminate する) でこのテストがクラッシュした待ち時間 (2026-10-27 に commit 4d9b421 で確認)
      try? await Task.sleep(nanoseconds: 1_000_000_000)
      return [first, await cachedItemCount(firestore: firestore)]
    }
    async let shortOperation: Int? = withWidgetFirestore(app: app) { firestore in
      await cachedItemCount(firestore: firestore)
    }
    let results = await longOperation + [shortOperation]
    XCTAssertEqual(results, [0, 0, 0])
  }

  /// 先の呼び出しで Firestore の操作が始まった後に、同じ app でもう一度呼んでも動くこと。
  /// 操作が始まった Firestore に違う settings を入れると SDK が例外を投げるため、2 回目の呼び出しで settings を入れ直さないことを確かめる
  func testSequentialOperationsOnSameApp() async {
    let app = makeFirebaseApp(name: "widget-sequential-\(UUID().uuidString)")
    let first = await withWidgetFirestore(app: app) { firestore in
      await cachedItemCount(firestore: firestore)
    }
    let second = await withWidgetFirestore(app: app) { firestore in
      await cachedItemCount(firestore: firestore)
    }
    XCTAssertEqual([first, second], [0, 0])
  }

  /// ウィジェット拡張の Firestore が LevelDB のローカルキャッシュを作らないこと。
  /// LevelDB を開かなければ、同じプロセスで LevelDB のロックを二重に取ること (Crashlytics issue cfc59876 の
  /// `LOCK: already held by process`) も、ロックを持ったまま suspend されること (0xdead10cc) も起きない
  func testOperationDoesNotCreateLevelDBDirectory() async throws {
    let appName = "widget-leveldb-\(UUID().uuidString)"
    let count = await withWidgetFirestore(app: makeFirebaseApp(name: appName)) { firestore in
      await cachedItemCount(firestore: firestore)
    }
    XCTAssertEqual(count, 0)
    // SDK が LevelDB を置く階層が版で変わっても見逃さないよう、firestore の下のどの階層でも app 名を含むパスが無いことを確かめる
    let firestoreDirectory = try FileManager.default
      .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
      .appendingPathComponent("firestore")
    XCTAssertEqual(
      (FileManager.default.subpaths(atPath: firestoreDirectory.path) ?? []).filter { $0.contains(appName) },
      [],
      firestoreDirectory.path
    )
  }
}
