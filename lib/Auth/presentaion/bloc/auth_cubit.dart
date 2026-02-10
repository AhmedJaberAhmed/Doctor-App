import 'package:flutter_bloc/flutter_bloc.dart';

import '../../get_session_user.dart';
import '../../sign_in.dart';
import '../../sign_up.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignUp signUpUc;
  final SignIn signInUc;
  final SignOut signOutUc;
  final GetSessionUser getCurrentUc;

  AuthCubit({
    required this.signUpUc,
    required this.signInUc,
    required this.signOutUc,
    required this.getCurrentUc,
  }) : super(const AuthUnknown());

  Future<void> init() async {
    emit(const AuthLoading());
    final res = await getCurrentUc();
    res.fold(
          (f) => emit(AuthUnauthenticated(message: f.message)),
          (auth) {
        if (auth == null) {
          emit(const AuthUnauthenticated());
        } else {
          emit(AuthAuthenticated(user: auth.user, profile: auth.profile));
        }
      },
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    emit(const AuthLoading());
    final res = await signUpUc(email: email, password: password, fullName: fullName, phone: phone);
    res.fold(
          (f) => emit(AuthUnauthenticated(message: f.message)),
          (auth) => emit(AuthAuthenticated(user: auth.user, profile: auth.profile)),
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    final res = await signInUc(email: email, password: password);
    res.fold(
          (f) => emit(AuthUnauthenticated(message: f.message)),
          (auth) => emit(AuthAuthenticated(user: auth.user, profile: auth.profile)),
    );
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    final res = await signOutUc();
    res.fold(
          (f) => emit(AuthUnauthenticated(message: f.message)),
          (_) => emit(const AuthUnauthenticated()),
    );
  }
}
