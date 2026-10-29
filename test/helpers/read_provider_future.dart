import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart';

/// [container] から [provider] の future を、値が出るまで購読を保ったまま読む。
///
/// Riverpod 3 は listener の無い autoDispose provider を値が出る前に破棄し、
/// `container.read(provider.future)` が StateError になるため、読み終えるまで listen する。
Future<T> readProviderFuture<T>({
  required ProviderContainer container,
  required ProviderListenable<Future<T>> provider,
}) {
  final subscription = container.listen(provider, (_, _) {});
  return subscription.read().whenComplete(subscription.close);
}
