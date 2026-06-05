import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/provider/toast.dart';

/// Toast の同一内容デデュープ（同一 identity の再 show を無視）の回帰テスト。
/// 同一通知が高頻度に再発行されてもタイマーがリセットされ続けて消えなくなる事象の修正を担保する。
void main() {
  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  const a = SizedBox(key: Key('a'));
  const b = SizedBox(key: Key('b'));

  test('表示中に同一 identity が来たら再 show を無視し、トーストを置き換えない', () {
    final container = makeContainer();
    final notifier = container.read(toastProvider.notifier);

    notifier.show(a, identity: 'same');
    notifier.show(b, identity: 'same');

    expect(
      container.read(toastProvider),
      same(a),
      reason: '同一 identity の再 show は無視され、最初のトーストが残る',
    );
    notifier.dismiss();
  });

  test('異なる identity の show は置き換える', () {
    final container = makeContainer();
    final notifier = container.read(toastProvider.notifier);

    notifier.show(a, identity: 'first');
    notifier.show(b, identity: 'second');

    expect(container.read(toastProvider), same(b));
    notifier.dismiss();
  });

  test('identity が null なら従来どおり毎回置き換える', () {
    final container = makeContainer();
    final notifier = container.read(toastProvider.notifier);

    notifier.show(a);
    notifier.show(b);

    expect(container.read(toastProvider), same(b));
    notifier.dismiss();
  });

  test('dismiss 後は同一 identity でも再表示される', () {
    final container = makeContainer();
    final notifier = container.read(toastProvider.notifier);

    notifier.show(a, identity: 'same');
    notifier.dismiss();
    expect(container.read(toastProvider), isNull);

    notifier.show(b, identity: 'same');
    expect(
      container.read(toastProvider),
      same(b),
      reason: '非表示状態(state==null)なら無視せず表示する',
    );
    notifier.dismiss();
  });
}
