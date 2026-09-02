import 'package:flutter/foundation.dart';

/// The three conditions any fetched collection can be in.
///
/// Sealed so a `switch` over it is exhaustive: adding a fourth condition
/// becomes a compile error at every site that renders one, rather than a state
/// silently falling through to the wrong branch.
@immutable
sealed class LoadState<T> {
  const LoadState();
}

final class Loading<T> extends LoadState<T> {
  const Loading();
}

final class Loaded<T> extends LoadState<T> {
  const Loaded(this.value);
  final T value;
}

final class LoadFailed<T> extends LoadState<T> {
  const LoadFailed(this.message);

  /// User-facing, and specific about what to do next.
  final String message;
}
