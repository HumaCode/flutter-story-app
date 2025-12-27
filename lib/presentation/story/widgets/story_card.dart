import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/variables.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../data/models/story_model.dart';
import '../blocs/delete_story/delete_story_bloc.dart';
import '../pages/edit_story_page.dart';
import '../pages/story_detail_page.dart';

class StoryCard extends StatefulWidget {
  final StoryModel story;
  final VoidCallback? onRefresh;

  const StoryCard({super.key, required this.story, this.onRefresh});

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  Future<void> _onTap() async {
    HapticFeedback.lightImpact();
    final result = await context.push(StoryDetailPage(story: widget.story));
    if (result == true) {
      widget.onRefresh?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isPressed
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.outline.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.black.withOpacity(0.04),
                blurRadius: _isPressed ? 20 : 12,
                offset: const Offset(0, 4),
                spreadRadius: _isPressed ? 2 : 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // ═══════════════════════════════════════════
                // DECORATIVE ELEMENTS (Background)
                // ═══════════════════════════════════════════

                // Circle decoration - top right
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.08),
                          AppColors.primary.withOpacity(0.03),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Circle decoration - bottom left
                Positioned(
                  bottom: -40,
                  left: -40,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.05),
                          AppColors.primary.withOpacity(0.02),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Small decorative dots pattern - positioned carefully
                if (widget.story.image == null)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _buildDotsPattern(
                      color: AppColors.primary.withOpacity(0.1),
                      dotSize: 4,
                      spacing: 10,
                      rows: 3,
                      cols: 3,
                    ),
                  ),

                // Subtle accent line at top
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.7),
                          AppColors.primary.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Corner accent - bottom right
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CustomPaint(
                    size: const Size(60, 60),
                    painter: CornerAccentPainter(
                      color: AppColors.primary.withOpacity(0.05),
                    ),
                  ),
                ),

                // ═══════════════════════════════════════════
                // MAIN CONTENT
                // ═══════════════════════════════════════════
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section dengan overlay gradient
                    if (widget.story.image != null) _buildImageSection(),

                    // Content Section
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          _buildTitle(),

                          const SizedBox(height: AppSizes.sm),

                          // Content Preview
                          _buildContentPreview(),

                          const SizedBox(height: AppSizes.md),

                          // Divider dengan dekorasi
                          _buildDecorativeDivider(),

                          const SizedBox(height: AppSizes.md),

                          // Footer
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget untuk membuat pola dots
  Widget _buildDotsPattern({
    required Color color,
    required double dotSize,
    required double spacing,
    required int rows,
    required int cols,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(rows, (row) {
        return Padding(
          padding: EdgeInsets.only(bottom: row < rows - 1 ? spacing : 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(cols, (col) {
              return Padding(
                padding: EdgeInsets.only(right: col < cols - 1 ? spacing : 0),
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildDecorativeDivider() {
    return Row(
      children: [
        // Left dots
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),

        // Line
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.2),
                  AppColors.outline.withOpacity(0.1),
                  AppColors.outline.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.2),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),
        // Right dots
        Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Image
        AspectRatio(
          aspectRatio: 16 / 9,
          child: CachedNetworkImage(
            imageUrl: '${Variables.baseUrl}/storage/${widget.story.image}',
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildImagePlaceholder(),
            errorWidget: (context, url, error) => _buildImageError(),
          ),
        ),

        // Gradient overlay di bawah
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
              ),
            ),
          ),
        ),

        // Decorative corner pattern on image
        Positioned(
          bottom: 8,
          right: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMiniDot(Colors.white.withOpacity(0.4)),
              const SizedBox(width: 4),
              _buildMiniDot(Colors.white.withOpacity(0.6)),
              const SizedBox(width: 4),
              _buildMiniDot(Colors.white.withOpacity(0.8)),
            ],
          ),
        ),

        // Badge "New" jika cerita baru (kurang dari 5 menit)
        if (_isNewStory())
          Positioned(
            top: AppSizes.sm,
            left: AppSizes.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 12,
                    color: AppColors.onPrimary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Baru',
                    style: TextStyle(
                      fontSize: AppSizes.fontXs,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Read time badge
        Positioned(
          top: AppSizes.sm,
          right: AppSizes.sm,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.story.formattedDate,
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
    );
  }

  Widget _buildMiniDot(Color color) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Memuat gambar...',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
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
              Icons.image_not_supported_outlined,
              color: AppColors.onSurfaceVariant.withOpacity(0.5),
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'Gambar tidak tersedia',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Small accent bar
        Container(
          width: 3,
          height: 20,
          margin: const EdgeInsets.only(right: AppSizes.sm, top: 2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.3)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: Text(
            widget.story.title,
            style: TextStyle(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildContentPreview() {
    return Padding(
      padding: const EdgeInsets.only(left: 11), // Align with title
      child: Text(
        widget.story.content,
        style: TextStyle(
          fontSize: AppSizes.fontMd,
          color: AppColors.onSurfaceVariant,
          height: 1.6,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // Author Info
        Expanded(
          child: Row(
            children: [
              // Avatar dengan gradient border
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.6),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.surface,
                  child: Text(
                    (widget.story.user?.name ?? 'U')
                        .substring(0, 1)
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),

              // Name & Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.story.user?.name ?? 'Unknown',
                      style: TextStyle(
                        fontSize: AppSizes.fontSm,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: AppColors.onSurfaceVariant.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.story.formattedDate,
                          style: TextStyle(
                            fontSize: AppSizes.fontXs,
                            color: AppColors.onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Action Buttons
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Edit Button
          _buildActionButton(
            icon: Icons.edit_outlined,
            color: AppColors.primary,
            tooltip: 'Edit',
            onTap: () async {
              HapticFeedback.lightImpact();
              final result = await context.push(
                EditStoryPage(story: widget.story),
              );
              if (result == true) {
                widget.onRefresh?.call();
              }
            },
          ),

          // Divider
          Container(
            width: 1,
            height: 20,
            color: AppColors.outline.withOpacity(0.2),
          ),

          // Delete Button
          _buildActionButton(
            icon: Icons.delete_outline_rounded,
            color: AppColors.error,
            tooltip: 'Hapus',
            onTap: () => _showDeleteConfirmation(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    HapticFeedback.mediumImpact();

    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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

            // Icon
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Title
            Text(
              'Hapus Cerita',
              style: TextStyle(
                fontSize: AppSizes.fontXl,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            // Message
            Text(
              'Apakah anda yakin ingin menghapus cerita "${widget.story.title}"?',
              style: TextStyle(
                fontSize: AppSizes.fontMd,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.sm),

            // Warning
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      'Tindakan ini tidak dapat dibatalkan',
                      style: TextStyle(
                        fontSize: AppSizes.fontSm,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: AppColors.outline.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Batal',
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Hapus',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom + AppSizes.sm,
            ),
          ],
        ),
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<DeleteStoryBloc>().add(
        DeleteStoryEvent.delete(widget.story.id),
      );
    }
  }

  bool _isNewStory() {
    // Cek apakah cerita dibuat dalam 5 menit terakhir
    final now = DateTime.now();
    final storyDate = widget.story.createdAt;
    if (storyDate == null) return false;
    return now.difference(storyDate).inMinutes <= 5;
  }

  int _calculateReadTime() {
    final wordCount = widget.story.content.split(' ').length;
    final readTime = (wordCount / 200).ceil();
    return readTime < 1 ? 1 : readTime;
  }
}

// Custom painter untuk corner accent
class CornerAccentPainter extends CustomPainter {
  final Color color;

  CornerAccentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.5, size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
