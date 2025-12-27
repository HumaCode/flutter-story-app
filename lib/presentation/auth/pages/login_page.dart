import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
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

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSizes.xxl),

                    // ═══════════════════════════════════════════
                    // HEADER
                    // ═══════════════════════════════════════════
                    _buildHeader(),

                    const SizedBox(height: AppSizes.xxl),

                    // ═══════════════════════════════════════════
                    // FORM
                    // ═══════════════════════════════════════════
                    _buildLoginForm(isLoading),

                    const SizedBox(height: AppSizes.lg),

                    // ═══════════════════════════════════════════
                    // LOGIN BUTTON
                    // ═══════════════════════════════════════════
                    AppButton(
                      text: 'Masuk',
                      onPressed: isLoading ? null : _login,
                      isLoading: isLoading,
                    ),

                    const SizedBox(height: AppSizes.lg),

                    // ═══════════════════════════════════════════
                    // DIVIDER
                    // ═══════════════════════════════════════════
                    _buildDivider(),

                    const SizedBox(height: AppSizes.lg),

                    // ═══════════════════════════════════════════
                    // REGISTER LINK
                    // ═══════════════════════════════════════════
                    _buildRegisterLink(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.auto_stories_rounded,
            size: AppSizes.iconXl * 1.5,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSizes.lg),

        // Title
        const Text(
          'Selamat Datang!',
          style: TextStyle(
            fontSize: AppSizes.fontXxl,
            fontWeight: FontWeight.bold,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: AppSizes.sm),

        // Subtitle
        Text(
          'Masuk untuk melanjutkan ke Story App',
          style: TextStyle(
            fontSize: AppSizes.fontMd,
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(bool isLoading) {
    return Column(
      children: [
        // Email Field
        AppTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'Masukkan email anda',
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
        const SizedBox(height: AppSizes.md),

        // Password Field
        AppTextField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Masukkan password anda',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          focusNode: _passwordFocusNode,
          enabled: !isLoading,
          onSubmitted: (_) => _login(),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.onSurfaceVariant,
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

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.divider)),
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
        Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum punya akun? ',
          style: TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: AppSizes.fontMd,
          ),
        ),
        TextButton(
          onPressed: () {
            context.push(const RegisterPage());
          },
          child: const Text(
            'Daftar Sekarang',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppSizes.fontMd,
            ),
          ),
        ),
      ],
    );
  }
}
