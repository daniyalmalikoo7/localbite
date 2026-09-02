/// A data fetch that did not succeed.
///
/// Carries a message written for the person reading the screen, not a stack
/// trace: it says what failed and what they can do about it.
class RepositoryException implements Exception {
  const RepositoryException(this.message);

  final String message;

  @override
  String toString() => 'RepositoryException: $message';
}
