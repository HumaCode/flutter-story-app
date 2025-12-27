import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_story/presentation/splash/widgets/animated_background.dart';
import '../../../core/components/app_text_field.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../story/pages/home_page.dart';
import '../blocs/register/register_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Animation Controllers
  late AnimationController _contentController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Password strength
  double _passwordStrength = 0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _initContentAnimation();
    _passwordController.addListener(_checkPasswordStrength);
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

  void _checkPasswordStrength() {
    String password = _passwordController.text;
    double strength = 0;
    String text = '';
    Color color = Colors.grey;

    if (password.isEmpty) {
      strength = 0;
      text = '';
    } else if (password.length < 6) {
      strength = 0.2;
      text = 'Sangat Lemah';
      color = Colors.red;
    } else if (password.length < 8) {
      strength = 0.4;
      text = 'Lemah';
      color = Colors.orange;
    } else {
      bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
      bool hasLowercase = password.contains(RegExp(r'[a-z]'));
      bool hasDigits = password.contains(RegExp(r'[0-9]'));
      bool hasSpecialChar = password.contains(
        RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
      );

      int complexity = 0;
      if (hasUppercase) complexity++;
      if (hasLowercase) complexity++;
      if (hasDigits) complexity++;
      if (hasSpecialChar) complexity++;

      if (complexity <= 1) {
        strength = 0.5;
        text = 'Sedang';
        color = Colors.yellow.shade700;
      } else if (complexity == 2) {
        strength = 0.7;
        text = 'Kuat';
        color = Colors.lightGreen;
      } else {
        strength = 1.0;
        text = 'Sangat Kuat';
        color = Colors.green;
      }
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = text;
      _passwordStrengthColor = color;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<RegisterBloc>().add(
        RegisterEvent.register(
          name: _nameController.text.trim(),
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
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          state.maybeWhen(
            success: (data) {
              context.showSuccess(
                'Registrasi berhasil! Selamat datang, ${data.user.name}!',
              );
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
              const AnimatedBackground(circleCount: 20, isDarkMode: false),

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
              // MAIN CONTENT (tanpa AppBar)
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
                            const SizedBox(height: AppSizes.xl),

                            // Header dengan animasi
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: _buildHeader(),
                            ),

                            const SizedBox(height: AppSizes.xxl),

                            // Form Card
                            _buildFormCard(isLoading),

                            const SizedBox(height: AppSizes.xl),

                            // Login Link
                            _buildLoginLink(),

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
                Icons.person_add_alt_1_rounded,
                size: AppSizes.iconXl * 1.5,
                color: AppColors.onPrimary,
              ),
            );
          },
        ),
        const SizedBox(height: AppSizes.lg),

        // Title
        Text(
          'Buat Akun Baru',
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
          'Bergabunglah dan mulai berbagi ceritamu',
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
                  Icons.edit_note_rounded,
                  color: AppColors.primary,
                  size: AppSizes.iconMd,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Akun',
                      style: TextStyle(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'Lengkapi data berikut',
                      style: TextStyle(
                        fontSize: AppSizes.fontSm,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.lg),

          // Name Field
          _buildNameField(isLoading),

          const SizedBox(height: AppSizes.md),

          // Email Field
          _buildEmailField(isLoading),

          const SizedBox(height: AppSizes.md),

          // Password Field
          _buildPasswordField(isLoading),

          // Password Strength Indicator
          if (_passwordController.text.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            _buildPasswordStrengthIndicator(),
          ],

          const SizedBox(height: AppSizes.md),

          // Confirm Password Field
          _buildConfirmPasswordField(isLoading),

          const SizedBox(height: AppSizes.lg),

          // Terms & Conditions
          _buildTermsCheckbox(),

          const SizedBox(height: AppSizes.lg),

          // Register Button
          _buildRegisterButton(isLoading),
        ],
      ),
    );
  }

  Widget _buildNameField(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nama Lengkap',
          style: TextStyle(
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        AppTextField(
          controller: _nameController,
          hint: 'Masukkan nama lengkap',
          prefixIcon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
          focusNode: _nameFocusNode,
          enabled: !isLoading,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(_emailFocusNode);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama tidak boleh kosong';
            }
            if (value.length < 3) {
              return 'Nama minimal 3 karakter';
            }
            return null;
          },
        ),
      ],
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
        Text(
          'Password',
          style: TextStyle(
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        AppTextField(
          controller: _passwordController,
          hint: 'Minimal 8 karakter',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          focusNode: _passwordFocusNode,
          enabled: !isLoading,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
          },
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
            if (value.length < 8) {
              return 'Password minimal 8 karakter';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                child: LinearProgressIndicator(
                  value: _passwordStrength,
                  backgroundColor: AppColors.outline.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _passwordStrengthColor,
                  ),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Text(
              _passwordStrengthText,
              style: TextStyle(
                fontSize: AppSizes.fontXs,
                color: _passwordStrengthColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          'Gunakan kombinasi huruf besar, kecil, angka & simbol',
          style: TextStyle(
            fontSize: AppSizes.fontXs,
            color: AppColors.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Konfirmasi Password',
          style: TextStyle(
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        AppTextField(
          controller: _confirmPasswordController,
          hint: 'Ulangi password',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          focusNode: _confirmPasswordFocusNode,
          enabled: !isLoading,
          onSubmitted: (_) => _register(),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.onSurfaceVariant,
              size: AppSizes.iconSm,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Konfirmasi password tidak boleh kosong';
            }
            if (value != _passwordController.text) {
              return 'Password tidak cocok';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: AppSizes.iconSm,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'Dengan mendaftar, Anda menyetujui '),
                  TextSpan(
                    text: 'Syarat & Ketentuan',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(text: ' dan '),
                  TextSpan(
                    text: 'Kebijakan Privasi',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(text: ' kami.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(bool isLoading) {
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
          onTap: isLoading ? null : _register,
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
                        Icons.how_to_reg_rounded,
                        color: AppColors.onPrimary,
                        size: AppSizes.iconSm,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        'Daftar Sekarang',
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

  Widget _buildLoginLink() {
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
            'Sudah punya akun?',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: AppSizes.fontMd,
            ),
          ),
          TextButton(
            onPressed: () => context.pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Masuk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.fontMd,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.login_rounded,
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
