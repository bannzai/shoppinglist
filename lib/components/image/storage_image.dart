import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Firebase Storage の [storagePath] から画像を表示する。
/// レシート画像・「写真から追加」の元画像など、storagePath ベースの画像表示の共通 widget。
///
/// download URL は Firestore に保存せず、表示時に storagePath から getDownloadURL で
/// 取得する（storage.rules で認証済みユーザーに read 許可）。取得した URL は
/// [CachedNetworkImage] でキャッシュする。storagePath は同一値ならキャッシュされ、
/// 再 build のたびに getDownloadURL を呼ばない（useMemoized）。
class StorageImage extends HookWidget {
  final String? storagePath;
  final double width;
  final double height;

  /// サムネイルは cover で埋め、拡大表示は contain で全体を見せる使い分けのため
  /// 指定可能にする。既定はサムネイル用途が多いため cover。
  final BoxFit fit;

  const StorageImage({
    super.key,
    required this.storagePath,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final path = storagePath;
    final urlFuture = useMemoized(
      () =>
          (path == null || path.isEmpty)
              ? Future<String?>.value(null)
              // Future() で遅延実行し、getDownloadURL までの同期例外
              // （Firebase 未初期化等）も snapshot.error に流す。
              : Future(
                () => FirebaseStorage.instance.ref(path).getDownloadURL(),
              ),
      [path],
    );
    final snapshot = useFuture(urlFuture);

    if (path == null || path.isEmpty || snapshot.hasError) {
      return _box(const Icon(Icons.broken_image));
    }
    final url = snapshot.data;
    if (url == null) {
      return _box(const Center(child: CircularProgressIndicator()));
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder:
          (context, _) =>
              _box(const Center(child: CircularProgressIndicator())),
      errorWidget: (context, _, _) => _box(const Icon(Icons.broken_image)),
    );
  }

  Widget _box(Widget child) =>
      SizedBox(width: width, height: height, child: child);
}
