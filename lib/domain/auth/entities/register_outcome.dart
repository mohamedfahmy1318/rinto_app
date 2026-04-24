import 'session.dart';

/// The three possible successful outcomes of a registration call.
///
/// Server response → outcome mapping:
///   token present                       → [RegisterAuthenticated]
///   requires_approval == true           → [RegisterPendingApproval]
///   requires_verification == true       → [RegisterNeedsVerification]
///
/// A failed registration throws `AuthException` from the repository
/// instead of producing an outcome.
sealed class RegisterOutcome {
  const RegisterOutcome();
}

class RegisterAuthenticated extends RegisterOutcome {
  const RegisterAuthenticated(this.session);
  final Session session;
}

class RegisterPendingApproval extends RegisterOutcome {
  const RegisterPendingApproval(this.message);
  final String message;
}

class RegisterNeedsVerification extends RegisterOutcome {
  const RegisterNeedsVerification(this.message);
  final String message;
}
