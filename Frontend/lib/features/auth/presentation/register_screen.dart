import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/failure.dart';
import '../../../core/utils/app_role.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/auth_scaffold.dart';
import '../../../shared/widgets/form_error_banner.dart';
import '../../../shared/widgets/permission_primer_sheet.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.initialRole = AppRole.student});
  final AppRole initialRole;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late AppRole _role = widget.initialRole;

  String? _nameError;
  String? _emailError;
  String? _passwordError;

  bool _validate() {
    setState(() {
      _nameError = _name.text.trim().length < 3 ? 'Name must be at least 3 characters' : null;
      _emailError = _email.text.trim().contains('@') ? null : 'Enter a valid email';
      _passwordError =
          _password.text.length < 8 ? 'Password must be at least 8 characters' : null;
    });
    return _nameError == null && _emailError == null && _passwordError == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    final controller = ref.read(authControllerProvider.notifier);

    final registered = await controller.register(
      name: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      role: _role.backendRole,
    );
    if (!registered || !mounted) return;

    final user = await controller.login(email: _email.text.trim(), password: _password.text);
    if (user == null || !mounted) return;

    await showNotificationPrimerSheet(
      context,
      message: 'Get notified the moment a new quiz is published or a student submits.',
    );

    if (mounted) context.go(AppRoutes.splash);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final failure = authState.hasError ? authState.error as Failure : null;

    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Join as a student or teacher',
      onBack: () => context.pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (failure != null) ...[
            FormErrorBanner(message: failure.message),
            const SizedBox(height: AppSpacing.md),
          ],
          Text("I'm a", style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          SegmentedControl<AppRole>(
            options: const [AppRole.student, AppRole.teacher],
            labels: const ['Student', 'Teacher'],
            selected: _role,
            onChanged: (r) => setState(() => _role = r),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: 'Full name', controller: _name, errorText: _nameError),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Email',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Password',
            controller: _password,
            obscureText: true,
            errorText: _passwordError,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: 'Create Account', isLoading: authState.isLoading, onPressed: _submit),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: TextButton(
              onPressed: () => context.pop(),
              child: const Text('Already have an account? Login'),
            ),
          ),
        ],
      ),
    );
  }
}
