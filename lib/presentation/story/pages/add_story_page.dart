import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_story/presentation/splash/widgets/animated_background.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../blocs/create_story/create_story_event_bloc.dart';

class AddStoryPage extends StatefulWidget {
  const AddStoryPage({super.key});

  @override
  State<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();
  File? _selectedImage;
  final _imagePicker = ImagePicker();

  // Animation
  late AnimationController _contentaController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Character count
  int _contentCharCount = 0;
  final int _maxContentLength = 2000;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _contentController.text.isEmpty;
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _initAnimations() {
    _contentaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentaController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentaController,
            curve: Curves.easeOutCubic,
          ),
        );

    _contentaController.forward();
  }

  void _onTextChanged() {
    setState(() {
      _contentCharCount = _contentController.text.length;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      context.showError('Gagal memilih gambar');
    }
  }

  void _showImageSourceDialog() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildImageSourceBottomSheet(),
    );
  }

  Widget _buildImageSourceBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_photo_alternate_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Text(
                'Pilih Sumber Gambar',
                style: TextStyle(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // Options
          Row(
            children: [
              Expanded(
                child: _buildImageSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  subtitle: 'Ambil foto',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _buildImageSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Galeri',
                  subtitle: 'Pilih foto',
                  color: const Color(0xFF10B981),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSizes.md),
        ],
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      context.read<CreateStoryBloc>().add(
        CreateStoryEvent.create(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          image: _selectedImage,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<CreateStoryBloc, CreateStoryState>(
        listener: (context, state) {
          state.maybeWhen(
            success: (story) {
              context.showSuccess('Cerita berhasil dibuat!');
              context.pop(true);
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
              // Animated Background
              const AnimatedBackground(circleCount: 12, isDarkMode: false),

              // Main Content
              SafeArea(
                child: Column(
                  children: [
                    // Custom App Bar
                    _buildAppBar(isLoading),

                    // Form Content
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(AppSizes.lg),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Image Picker
                                  _buildImagePicker(),

                                  const SizedBox(height: AppSizes.lg),

                                  // Form Card
                                  _buildFormCard(isLoading),

                                  const SizedBox(height: AppSizes.lg),

                                  // Tips Card
                                  _buildTipsCard(),

                                  const SizedBox(height: AppSizes.xl),

                                  // Submit Button
                                  _buildSubmitButton(isLoading),

                                  const SizedBox(height: AppSizes.lg),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(bool isLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.sm,
      ),
      child: Row(
        children: [
          // Close Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : () => context.pop(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline.withOpacity(0.1)),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.onSurface,
                  size: 22,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSizes.md),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buat Cerita Baru',
                  style: TextStyle(
                    fontSize: AppSizes.fontLg,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
                ),
                Text(
                  'Bagikan momen berhargamu',
                  style: TextStyle(
                    fontSize: AppSizes.fontXs,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Draft indicator (optional)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Draft',
                  style: TextStyle(
                    fontSize: AppSizes.fontXs,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _selectedImage != null ? 220 : 160,
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selectedImage != null
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.outline.withOpacity(0.2),
            width: 2,
            style: _selectedImage != null
                ? BorderStyle.solid
                : BorderStyle.none,
          ),
          boxShadow: [
            BoxShadow(
              color: _selectedImage != null
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Decorative elements
              if (_selectedImage == null) ...[
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  left: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.03),
                    ),
                  ),
                ),
              ],

              // Image or Placeholder
              if (_selectedImage != null)
                Image.file(_selectedImage!, fit: BoxFit.cover)
              else
                _buildImagePlaceholder(),

              // Overlay gradient (when image selected)
              if (_selectedImage != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ),

              // Action buttons (when image selected)
              if (_selectedImage != null)
                Positioned(
                  bottom: AppSizes.sm,
                  left: AppSizes.sm,
                  right: AppSizes.sm,
                  child: Row(
                    children: [
                      // Change image button
                      Expanded(
                        child: _buildImageActionButton(
                          icon: Icons.refresh_rounded,
                          label: 'Ganti',
                          onTap: _showImageSourceDialog,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      // Remove image button
                      _buildImageActionButton(
                        icon: Icons.delete_outline_rounded,
                        label: 'Hapus',
                        isDestructive: true,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),

              // Add image badge (when image selected)
              if (_selectedImage != null)
                Positioned(
                  top: AppSizes.sm,
                  left: AppSizes.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: AppColors.onPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Gambar dipilih',
                          style: TextStyle(
                            fontSize: AppSizes.fontXs,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add_photo_alternate_rounded,
            size: 36,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Text(
          'Tambahkan Gambar',
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap untuk memilih dari kamera atau galeri',
          style: TextStyle(
            color: AppColors.onSurfaceVariant.withOpacity(0.7),
            fontSize: AppSizes.fontXs,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Opsional',
            style: TextStyle(
              fontSize: AppSizes.fontXs,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.2)
                : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDestructive
                  ? Colors.red.withOpacity(0.3)
                  : Colors.white.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isDestructive ? Colors.red.shade200 : Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red.shade200 : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Detail Cerita',
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.lg),

          // Title Field
          _buildInputLabel('Judul Cerita', Icons.title_rounded, true),
          const SizedBox(height: AppSizes.xs),
          _buildTextField(
            controller: _titleController,
            focusNode: _titleFocusNode,
            hint: 'Masukkan judul yang menarik...',
            enabled: !isLoading,
            maxLines: 1,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) {
              FocusScope.of(context).requestFocus(_contentFocusNode);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Judul tidak boleh kosong';
              }
              if (value.length < 5) {
                return 'Judul minimal 5 karakter';
              }
              return null;
            },
          ),

          const SizedBox(height: AppSizes.lg),

          // Content Field
          _buildInputLabel('Isi Cerita', Icons.article_rounded, true),
          const SizedBox(height: AppSizes.xs),
          _buildTextField(
            controller: _contentController,
            focusNode: _contentFocusNode,
            hint: 'Tulis cerita menarikmu di sini...',
            enabled: !isLoading,
            maxLines: 6,
            maxLength: _maxContentLength,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Isi cerita tidak boleh kosong';
              }
              if (value.length < 20) {
                return 'Isi cerita minimal 20 karakter';
              }
              return null;
            },
          ),

          // Character count
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$_contentCharCount / $_maxContentLength',
              style: TextStyle(
                fontSize: AppSizes.fontXs,
                color: _contentCharCount > _maxContentLength * 0.9
                    ? AppColors.error
                    : AppColors.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label, IconData icon, bool isRequired) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required bool enabled,
    required int maxLines,
    int? maxLength,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: TextStyle(fontSize: AppSizes.fontMd, color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.onSurfaceVariant.withOpacity(0.5),
        ),
        filled: true,
        fillColor: AppColors.surfaceVariant.withOpacity(0.3),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.outline.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.error.withOpacity(0.5)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(AppSizes.md),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082).withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB300).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              size: 18,
              color: Color(0xFFFF8F00),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tips Menulis Cerita',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gunakan judul yang menarik dan deskriptif. Ceritakan pengalamanmu dengan detail yang vivid!',
                  style: TextStyle(
                    fontSize: AppSizes.fontXs,
                    color: const Color(0xFFE65100).withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isLoading
              ? [
                  AppColors.primary.withOpacity(0.5),
                  AppColors.primary.withOpacity(0.3),
                ]
              : [AppColors.primary, AppColors.primary.withOpacity(0.85)],
        ),
        boxShadow: isLoading
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : _submit,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        'Mempublikasikan...',
                        style: TextStyle(
                          fontSize: AppSizes.fontMd,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send_rounded,
                        color: AppColors.onPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        'Publikasikan Cerita',
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
}
