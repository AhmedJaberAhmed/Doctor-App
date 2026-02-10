import 'package:doctor_app/Auth/presentaion/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth_cubit.dart';
import 'bloc/auth_state.dart';


class AuthGate extends StatefulWidget {
  final Widget userHome;
  final Widget adminHome;

  const AuthGate({
    super.key,
    required this.userHome,
    required this.adminHome,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthUnknown) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthUnauthenticated) {
          return
            SignInPage(errorText: state.message);
        }

        if (state is AuthAuthenticated) {
          // Your profiles.role is 'user' or 'admin'
          if (state.profile.role == 'admin') return widget.adminHome;
          return widget.userHome;
        }

        return const SizedBox.shrink();
      },
    );
  }
}
