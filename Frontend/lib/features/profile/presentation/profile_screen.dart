import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_gradients.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/widgets/confirm_bottom_sheet.dart';
import '../../auth/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: sessionAsync.when(
        loading: () => const SizedBox(),
        error: (_, __) => const SizedBox(),
        data: (session) {
          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: AppRadii.heroBottomOnly,
                  boxShadow: AppShadows.hero,
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.ink,
                          child: Text(
                            (session.name?.isNotEmpty ?? false)
                                ? session.name![0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppColors.pureWhite,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            gradient: AppGradients.indigoViolet,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            size: 12,
                            color: AppColors.pureWhite,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(session.name ?? '', style: theme.textTheme.displaySmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(session.email ?? '', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentIndigo.withValues(alpha: 0.1),
                        borderRadius: AppRadii.smRadius,
                        border: Border.all(
                          color: AppColors.accentIndigo.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        session.role?.label ?? '',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.accentIndigo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text('Settings', style: theme.textTheme.displaySmall),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: AppRadii.lgRadius,
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    children: [
                      _ProfileRow(
                        icon: Icons.info_outline_rounded,
                        label: 'Profile details',
                        subtitle: 'Grade, subjects, and expertise — coming soon',
                      ),
                      Divider(height: 1, color: theme.colorScheme.outlineVariant),
                      _ProfileRow(
                        icon: Icons.dark_mode_outlined,
                        label: 'Appearance',
                        subtitle: 'Follows system theme',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  onPressed: () async {
                    final confirmed = await showConfirmBottomSheet(
                      context,
                      title: 'Log out?',
                      message: "You'll need to log in again to access your account.",
                      confirmLabel: 'Log out',
                    );
                    if (confirmed) {
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) context.go(AppRoutes.splash);
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log out'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.icon, required this.label, this.subtitle});
  final IconData icon;
  final String label;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              borderRadius: AppRadii.smRadius,
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.outline),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                if (subtitle != null) Text(subtitle!, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.outline,
            size: 20,
          ),
        ],
      ),
    );
  }
}
