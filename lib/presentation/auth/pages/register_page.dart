import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/components/app_button.dart';
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

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => context.pop(),
        ),
      ),
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

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ═══════════════════════════════════════════
                    // HEADER
                    // ═══════════════════════════════════════════
                    _buildHeader(),

                    const SizedBox(height: AppSizes.xl),

                    // ═══════════════════════════════════════════
                    // FORM
                    // ═══════════════════════════════════════════
                    _buildRegisterForm(isLoading),

                    const SizedBox(height: AppSizes.lg),

                    // ═══════════════════════════════════════════
                    // REGISTER BUTTON
                    // ═══════════════════════════════════════════
                    AppButton(
                      text: 'Daftar',
                      onPressed: isLoading ? null : _register,
                      isLoading: isLoading,
                    ),

                    const SizedBox(height: AppSizes.lg),

                    // ═══════════════════════════════════════════
                    // LOGIN LINK
                    // ═══════════════════════════════════════════
                    _buildLoginLink(),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Buat Akun Baru',
          style: TextStyle(
            fontSize: AppSizes.fontXxl,
            fontWeight: FontWeight.bold,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          'Isi form berikut untuk mendaftar',
          style: TextStyle(
            fontSize: AppSizes.fontMd,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(bool isLoading) {
    return Column(
      children: [
        // Name Field
        AppTextField(
          controller: _nameController,
          label: 'Nama Lengkap',
          hint: 'Masukkan nama lengkap anda',
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
          enabled: !isLoading,
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
        const SizedBox(height: AppSizes.md),

        // Email Field
        AppTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'Masukkan email anda',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !isLoading,
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
          hint: 'Minimal 8 karakter',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          enabled: !isLoading,
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
            if (value.length < 8) {
              return 'Password minimal 8 karakter';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSizes.md),

        // Confirm Password Field
        AppTextField(
          controller: _confirmPasswordController,
          label: 'Konfirmasi Password',
          hint: 'Ulangi password anda',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          enabled: !isLoading,
          onSubmitted: (_) => _register(),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.onSurfaceVariant,
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

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: AppSizes.fontMd,
          ),
        ),
        TextButton(
          onPressed: () => context.pop(),
          child: const Text(
            'Masuk',
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
