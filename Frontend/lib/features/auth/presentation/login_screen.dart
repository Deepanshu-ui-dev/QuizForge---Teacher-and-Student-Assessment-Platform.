import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/auth_scaffold.dart';
import '../../../shared/widgets/form_error_banner.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;

  bool _validate() {
    setState(() {
      _emailError = _email.text.trim().contains('@') ? null : 'Enter a valid email';
      _passwordError = _password.text.isEmpty ? 'Password is required' : null;
    });
    return _emailError == null && _passwordError == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    final user = await ref.read(authControllerProvider.notifier).login(
          email: _email.text.trim(),
          password: _password.text,
        );
    if (user != null && mounted) {
      context.go(AppRoutes.splash);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final failure = authState.hasError ? authState.error as Failure : null;

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Log in to continue',
      onBack: () => context.pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (failure != null) ...[
            FormErrorBanner(message: failure.message),
            const SizedBox(height: AppSpacing.md),
          ],
          AppTextField(
            label: 'Email',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Password',
            controller: _password,
            obscureText: true,
            errorText: _passwordError,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Login',
            isLoading: authState.isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: TextButton(
              onPressed: () => context.push(AppRoutes.register),
              child: const Text("Don't have an account? Create one"),
            ),
          ),
        ],
      ),
    );
  }
}
