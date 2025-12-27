import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/components/error_state.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../auth/blocs/logout/logout_bloc.dart';
import '../../auth/pages/login_page.dart';
import '../blocs/profile/profile_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileEvent.getProfile());
  }

  Future<void> _confirmLogout() async {
    final confirm = await context.showConfirmDialog(
      title: 'Logout',
      message: 'Apakah anda yakin ingin keluar?',
      confirmText: 'Logout',
      confirmColor: AppColors.error,
    );

    if (confirm == true && mounted) {
      context.read<LogoutBloc>().add(const LogoutEvent.logout());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogoutBloc, LogoutState>(
      listener: (context, state) {
        state.maybeWhen(
          success: () {
            context.pushAndRemoveUntil(const LoginPage(), (route) => false);
          },
          error: (message) {
            context.showError(message);
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: const Text(
            'Profil',
            style: TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            return state.when(
              initial: () => const LoadingIndicator(),
              loading: () =>
                  const LoadingIndicator(message: 'Memuat profil...'),
              success: (user) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSizes.lg),

                      // Avatar
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primaryContainer,
                        child: Text(
                          user.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),

                      // Name
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: AppSizes.fontXxl,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),

                      // Email
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: AppSizes.fontMd,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xl),

                      // Profile Info Card
                      _buildInfoCard(user),
                      const SizedBox(height: AppSizes.lg),

                      // Logout Button
                      _buildLogoutButton(),
                    ],
                  ),
                );
              },
              error: (message) => ErrorState(
                message: message,
                onRetry: () {
                  context.read<ProfileBloc>().add(
                    const ProfileEvent.getProfile(),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(user) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Nama',
              value: user.name,
            ),
            const Divider(height: AppSizes.lg),
            _buildInfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user.email,
            ),
            const Divider(height: AppSizes.lg),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Bergabung',
              value: user.createdAt != null
                  ? '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                  : '-',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return BlocBuilder<LogoutBloc, LogoutState>(
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : _confirmLogout,
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout, color: AppColors.error),
            label: Text(
              isLoading ? 'Logging out...' : 'Logout',
              style: const TextStyle(color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        );
      },
    );
  }
}
