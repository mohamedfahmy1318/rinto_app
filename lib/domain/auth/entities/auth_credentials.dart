import 'package:equatable/equatable.dart';

/// Login input: phone-or-email identifier + password.
/// Server-side disambiguates which identifier the user provided.
class AuthCredentials extends Equatable {
  const AuthCredentials({required this.login, required this.password});

  final String login;
  final String password;

  @override
  List<Object?> get props => [login, password];
}
