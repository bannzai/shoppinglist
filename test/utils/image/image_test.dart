import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart';
import 'package:shoppinglist/utils/image/image.dart';

void main() {
  // 高周波な内容を持つテスト用画像を生成する。
  // JPEG quality の差がファイルサイズに表れるよう、隣接ピクセルで値が変化する模様にする。
  Image makeNoisyImage(int width, int height) {
    final image = Image(width: width, height: height);
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        image.setPixelRgb(x, y, (x * 7) % 256, (y * 13) % 256, (x * y) % 256);
      }
    }
    return image;
  }

  Future<File> writePng(Image image) async {
    final dir = await Directory.systemTemp.createTemp('image_test');
    final file = File('${dir.path}/source.png');
    await file.writeAsBytes(encodePng(image));
    return file;
  }

  group('base64CompressImage', () {
    test('長辺を1000pxに縮小したJPEGをbase64で返す', () async {
      final file = await writePng(makeNoisyImage(2000, 1000));

      final decoded = decodeImage(
        base64Decode(await base64CompressImage(file)),
      );

      expect(decoded, isNotNull);
      // 長辺2000 → 1000 に縮小し、短辺は比率維持で500になる。
      expect(decoded!.width, 1000);
      expect(decoded.height, 500);
    });

    test('JPEGフォーマット（SOIマーカー）でエンコードされている', () async {
      final bytes = base64Decode(
        await base64CompressImage(await writePng(makeNoisyImage(1200, 800))),
      );

      expect(bytes[0], 0xFF);
      expect(bytes[1], 0xD8);
    });

    test('quality 100 よりファイルサイズが小さい（圧縮が効いている）', () async {
      final source = makeNoisyImage(1000, 1000);
      final compressed = base64Decode(
        await base64CompressImage(await writePng(source)),
      );
      // base64CompressImage と同じ寸法（長辺1000）で quality 100 エンコードした基準。
      final reference = encodeJpg(source, quality: 100);

      expect(compressed.length, lessThan(reference.length));
    });
  });
}
