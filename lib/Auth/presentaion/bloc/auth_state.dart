
import '../../domain/AppUser.dart';
import '../../domain/Profile.dart';

sealed class AuthState {
  const AuthState();
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthUnauthenticated extends AuthState {
  final String? message;
  const AuthUnauthenticated({this.message});
}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  final Profile profile;
  const AuthAuthenticated({required this.user, required this.profile});
}
