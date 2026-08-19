
sealed class Failure {
  const Failure(this.message);

  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network.']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Your session has expired. Please log in again.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.fieldErrors = const {}});

  final Map<String, String> fieldErrors;
}

class ServerFailure extends Failure {
  const ServerFailure(this.statusCode, super.message);

  final int statusCode;
}

class BackendNotImplementedFailure extends Failure {
  const BackendNotImplementedFailure([
    super.message = 'This feature is not available yet — the backend endpoint is still being built.',
  ]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong. Please try again.']);
}
