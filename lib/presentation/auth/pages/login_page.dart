import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_story/presentation/splash/widgets/animated_background.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_text_field.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../story/pages/home_page.dart';
import '../blocs/login/login_bloc.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  // Animation Controllers
  late AnimationController _contentController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initContentAnimation();
  }

  void _initContentAnimation() {
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _contentController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<LoginBloc>().add(
        LoginEvent.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          state.maybeWhen(
            success: (data) {
              context.showSuccess('Selamat datang, ${data.user.name}!');
              context.pushAndRemoveUntil(const HomePage(), (route) => false);
            },
            error: (message) {
              context.showError(message);
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return Stack(
            children: [
              // ═══════════════════════════════════════════
              // ANIMATED BACKGROUND (Light Mode)
              // ═══════════════════════════════════════════
              const AnimatedBackground(
                circleCount: 20,
                isDarkMode: false, // Pakai light mode
              ),

              // ═══════════════════════════════════════════
              // GRADIENT OVERLAY untuk depth
              // ═══════════════════════════════════════════
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.5,
                    colors: [
                      Colors.transparent,
                      AppColors.background.withOpacity(0.3),
                    ],
                  ),
                ),
              ),

              // ═══════════════════════════════════════════
              // MAIN CONTENT
              // ═══════════════════════════════════════════
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.lg,
                    vertical: AppSizes.md,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: AppSizes.xxl),

                            // Header dengan animasi
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: _buildHeader(),
                            ),

                            const SizedBox(height: AppSizes.xxl),

                            // Form Card dengan glassmorphism
                            _buildFormCard(isLoading),

                            const SizedBox(height: AppSizes.xl),

                            // Register Link
                            _buildRegisterLink(),

                            const SizedBox(height: AppSizes.lg),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Animated Logo dengan glow effect
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1500),
          builder: (context, value, child) {
            return Container(
              padding: const EdgeInsets.all(AppSizes.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3 * value),
                    blurRadius: 30 * value,
                    spreadRadius: 5 * value,
                  ),
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15 * value),
                    blurRadius: 60 * value,
                    spreadRadius: 15 * value,
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                size: AppSizes.iconXl * 1.5,
                color: AppColors.onPrimary,
              ),
            );
          },
        ),
        const SizedBox(height: AppSizes.lg),

        // Title
        Text(
          'Selamat Datang!',
          style: TextStyle(
            fontSize: AppSizes.fontXxl + 4,
            fontWeight: FontWeight.bold,
            color: AppColors.onBackground,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSizes.sm),

        // Subtitle
        Text(
          'Masuk untuk melanjutkan ke Story App',
          style: TextStyle(
            fontSize: AppSizes.fontMd,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormCard(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.outline.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Form Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(
                  Icons.login_rounded,
                  color: AppColors.primary,
                  size: AppSizes.iconMd,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Text(
                'Masuk ke Akun',
                style: TextStyle(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.lg),

          // Email Field
          _buildEmailField(isLoading),

          const SizedBox(height: AppSizes.md),

          // Password Field
          _buildPasswordField(isLoading),

          const SizedBox(height: AppSizes.lg),

          // Login Button
          _buildLoginButton(isLoading),

          const SizedBox(height: AppSizes.md),

          // Divider
          _buildDivider(),

          const SizedBox(height: AppSizes.md),

          // Social Login Hint
          _buildSocialLoginHint(),
        ],
      ),
    );
  }

  Widget _buildEmailField(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: TextStyle(
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        AppTextField(
          controller: _emailController,
          hint: 'contoh@email.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          focusNode: _emailFocusNode,
          enabled: !isLoading,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email tidak boleh kosong';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Format email tidak valid';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password',
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                // Forgot password action
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Lupa Password?',
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.xs),
        AppTextField(
          controller: _passwordController,
          hint: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          focusNode: _passwordFocusNode,
          enabled: !isLoading,
          onSubmitted: (_) => _login(),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.onSurfaceVariant,
              size: AppSizes.iconSm,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        gradient: LinearGradient(
          colors: isLoading
              ? [
                  AppColors.primary.withOpacity(0.6),
                  AppColors.primary.withOpacity(0.4),
                ]
              : [AppColors.primary, AppColors.primary.withOpacity(0.85)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: isLoading
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : _login,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.onPrimary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.login_rounded,
                        color: AppColors.onPrimary,
                        size: AppSizes.iconSm,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: AppSizes.fontMd,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.outline.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Text(
            'atau',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: AppSizes.fontSm,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.outline.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginHint() {
    return Center(
      child: Text(
        'Fitur login sosial akan segera hadir',
        style: TextStyle(
          fontSize: AppSizes.fontSm,
          color: AppColors.onSurfaceVariant.withOpacity(0.7),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.md,
        horizontal: AppSizes.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Belum punya akun?',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: AppSizes.fontMd,
            ),
          ),
          TextButton(
            onPressed: () {
              context.push(const RegisterPage());
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Daftar Sekarang',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.fontMd,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: AppSizes.iconSm,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
