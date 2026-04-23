/// Typed failure surface returned (eventually) from the network layer.
///
/// v1 of feature `001-core-network-di` ships only the hierarchy shape
/// and the [UnexpectedFailure] catch-all. Concrete mapping from
/// `DioException` types into the other subclasses is delivered by a
/// follow-up feature; subclasses are defined now so call sites can
/// depend on the stable shape.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});

  final int? statusCode;

  @override
  String toString() => 'ServerFailure($statusCode, $message)';
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
