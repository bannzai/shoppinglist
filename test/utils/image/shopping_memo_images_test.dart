import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart';
import 'package:shoppinglist/utils/image/image.dart';

/// 「写真から追加」検証用フィクスチャ（test/fixtures/shopping_memo_images/）が
/// アプリのアップロード前処理で扱える状態であることを保証するテスト。
/// フィクスチャの用途・使い方は同ディレクトリの README.md を参照。
void main() {
  // flutter test の作業ディレクトリはプロジェクトルートのため相対パスで参照できる。
  final fixtureFiles =
      Directory('test/fixtures/shopping_memo_images')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.jpg'))
          .toList();

  group('shopping_memo_images フィクスチャ', () {
    test('買い物メモ画像が2枚以上存在する（複数枚選択の検証に使うため）', () {
      expect(fixtureFiles.length, greaterThanOrEqualTo(2));
    });

    test('base64CompressImage で長辺1000px以下のJPEGに変換できる', () async {
      for (final fixtureFile in fixtureFiles) {
        final decoded = decodeImage(
          base64Decode(await base64CompressImage(fixtureFile)),
        );
        expect(decoded, isNotNull, reason: fixtureFile.path);
        expect(
          decoded!.width <= 1000 && decoded.height <= 1000,
          isTrue,
          reason: fixtureFile.path,
        );
      }
    });
  });
}
