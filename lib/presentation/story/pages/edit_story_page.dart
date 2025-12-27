import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_story/presentation/splash/widgets/animated_background.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/variables.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../data/models/story_model.dart';
import '../blocs/update_story/update_story_bloc.dart';

class EditStoryPage extends StatefulWidget {
  final StoryModel story;

  const EditStoryPage({super.key, required this.story});

  @override
  State<EditStoryPage> createState() => _EditStoryPageState();
}

class _EditStoryPageState extends State<EditStoryPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();
  File? _selectedImage;
  bool _imageChanged = false;
  bool _removeImage = false;
  final _imagePicker = ImagePicker();

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Character count
  int _contentCharCount = 0;
  final int _maxContentLength = 2000;

  // Track changes
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.story.title);
    _contentController = TextEditingController(text: widget.story.content);
    _contentCharCount = widget.story.content.length;

    _initAnimations();
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  void _onTextChanged() {
    setState(() {
      _contentCharCount = _contentController.text.length;
      _hasChanges =
          _titleController.text != widget.story.title ||
          _contentController.text != widget.story.content ||
          _imageChanged;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _animationController.dispose();
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
          _imageChanged = true;
          _removeImage = false;
          _hasChanges = true;
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
    final hasImage =
        (widget.story.image != null && !_removeImage) || _selectedImage != null;

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
                child: Icon(Icons.edit_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: AppSizes.md),
              Text(
                hasImage ? 'Ubah Gambar' : 'Tambah Gambar',
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

          // Remove image option
          if (hasImage) ...[
            const SizedBox(height: AppSizes.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                    _imageChanged = true;
                    _removeImage = true;
                    _hasChanges = true;
                  });
                  HapticFeedback.lightImpact();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                label: Text(
                  'Hapus Gambar',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],

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

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDiscardChangesSheet(),
    );

    return result ?? false;
  }

  Widget _buildDiscardChangesSheet() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSizes.md),

          Text(
            'Perubahan Belum Disimpan',
            style: TextStyle(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.sm),

          Text(
            'Anda memiliki perubahan yang belum disimpan. Yakin ingin keluar?',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.xl),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.outline.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Kembali',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Buang',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSizes.sm),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      context.read<UpdateStoryBloc>().add(
        UpdateStoryEvent.update(
          id: widget.story.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          image: _imageChanged ? _selectedImage : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<UpdateStoryBloc, UpdateStoryState>(
          listener: (context, state) {
            state.maybeWhen(
              success: (story) {
                context.showSuccess('Cerita berhasil diperbarui!');
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Image Picker
                                    _buildImagePicker(),

                                    const SizedBox(height: AppSizes.lg),

                                    // Form Card
                                    _buildFormCard(isLoading),

                                    const SizedBox(height: AppSizes.lg),

                                    // Info Card
                                    _buildInfoCard(),

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
              onTap: isLoading
                  ? null
                  : () async {
                      if (await _onWillPop()) {
                        context.pop();
                      }
                    },
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
                  'Edit Cerita',
                  style: TextStyle(
                    fontSize: AppSizes.fontLg,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
                ),
                Text(
                  'Perbarui ceritamu',
                  style: TextStyle(
                    fontSize: AppSizes.fontXs,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Change indicator
          if (_hasChanges)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    'Diubah',
                    style: TextStyle(
                      fontSize: AppSizes.fontXs,
                      color: Colors.orange,
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
    final hasExistingImage =
        widget.story.image != null && !_imageChanged && !_removeImage;
    final hasNewImage = _selectedImage != null;
    final hasAnyImage = hasExistingImage || hasNewImage;

    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: hasAnyImage ? 220 : 160,
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasAnyImage
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.outline.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: hasAnyImage
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
              // Decorative elements (when no image)
              if (!hasAnyImage) ...[
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

              // Image display
              if (hasExistingImage)
                CachedNetworkImage(
                  imageUrl:
                      '${Variables.baseUrl}/storage/${widget.story.image}',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildImageLoading(),
                  errorWidget: (context, url, error) => _buildImageError(),
                )
              else if (hasNewImage)
                Image.file(_selectedImage!, fit: BoxFit.cover)
              else
                _buildImagePlaceholder(),

              // Gradient overlay
              if (hasAnyImage)
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

              // Action buttons
              if (hasAnyImage)
                Positioned(
                  bottom: AppSizes.sm,
                  left: AppSizes.sm,
                  right: AppSizes.sm,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildImageActionButton(
                          icon: Icons.refresh_rounded,
                          label: 'Ganti',
                          onTap: _showImageSourceDialog,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      _buildImageActionButton(
                        icon: Icons.delete_outline_rounded,
                        label: 'Hapus',
                        isDestructive: true,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedImage = null;
                            _imageChanged = true;
                            _removeImage = true;
                            _hasChanges = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),

              // Status badge
              if (hasAnyImage)
                Positioned(
                  top: AppSizes.sm,
                  left: AppSizes.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _imageChanged ? Colors.orange : AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _imageChanged
                              ? Icons.swap_horiz_rounded
                              : Icons.check_circle_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _imageChanged ? 'Gambar baru' : 'Gambar saat ini',
                          style: TextStyle(
                            fontSize: AppSizes.fontXs,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
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
      ],
    );
  }

  Widget _buildImageLoading() {
    return Container(
      color: AppColors.surfaceVariant,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: AppColors.surfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 40,
              color: AppColors.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Gagal memuat gambar',
              style: TextStyle(
                fontSize: AppSizes.fontXs,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi',
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Perubahan akan langsung tersimpan setelah Anda menekan tombol simpan.',
                  style: TextStyle(
                    fontSize: AppSizes.fontXs,
                    color: AppColors.onSurfaceVariant,
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
          colors: isLoading || !_hasChanges
              ? [
                  AppColors.primary.withOpacity(0.5),
                  AppColors.primary.withOpacity(0.3),
                ]
              : [AppColors.primary, AppColors.primary.withOpacity(0.85)],
        ),
        boxShadow: isLoading || !_hasChanges
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
          onTap: isLoading || !_hasChanges ? null : _submit,
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
                        'Menyimpan...',
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
                        Icons.save_rounded,
                        color: AppColors.onPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        'Simpan Perubahan',
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
