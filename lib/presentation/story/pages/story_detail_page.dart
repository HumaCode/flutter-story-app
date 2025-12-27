import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_story/presentation/splash/widgets/animated_background.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/variables.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../data/models/story_model.dart';
import '../blocs/delete_story/delete_story_bloc.dart';
import 'edit_story_page.dart';

class StoryDetailPage extends StatefulWidget {
  final StoryModel story;

  const StoryDetailPage({super.key, required this.story});

  @override
  State<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  double _scrollOffset = 0;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
      _showTitle = _scrollOffset > 200;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteStoryBloc, DeleteStoryState>(
      listener: (context, state) {
        state.maybeWhen(
          success: (message) {
            context.showSuccess(message);
            context.pop(true);
          },
          error: (message) {
            context.showError(message);
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Animated Background (visible when no image or scrolled)
            const AnimatedBackground(circleCount: 10, isDarkMode: false),

            // Main Content
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Custom App Bar
                _buildSliverAppBar(context),

                // Content
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final hasImage = widget.story.image != null;

    return SliverAppBar(
      expandedHeight: hasImage ? 320 : 120,
      pinned: true,
      stretch: true,
      backgroundColor: _showTitle
          ? AppColors.surface.withOpacity(0.95)
          : Colors.transparent,
      elevation: _showTitle ? 1 : 0,
      leading: _buildBackButton(),
      actions: [
        _buildShareButton(),
        const SizedBox(width: AppSizes.sm),
      ],
      title: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _showTitle ? 1.0 : 0.0,
        child: Text(
          widget.story.title,
          style: TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      flexibleSpace: hasImage
          ? FlexibleSpaceBar(
              background: _buildHeroImage(),
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
            )
          : FlexibleSpaceBar(background: _buildNoImageHeader()),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: _showTitle ? Colors.transparent : Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => context.pop(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back_rounded,
              color: _showTitle ? AppColors.onSurface : Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: _showTitle ? Colors.transparent : Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            // Share functionality
            context.showSuccess('Fitur berbagi akan segera hadir!');
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.share_rounded,
              color: _showTitle ? AppColors.onSurface : Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image
        CachedNetworkImage(
          imageUrl: '${Variables.baseUrl}/storage/${widget.story.image}',
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppColors.surfaceVariant,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColors.surfaceVariant,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 48,
                  color: AppColors.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gagal memuat gambar',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: AppSizes.fontSm,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Gradient overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 150,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),
        ),

        // Top gradient for status bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.5), Colors.transparent],
              ),
            ),
          ),
        ),

        // Read time badge
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_calculateReadTime()} min baca',
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

        // Decorative dots
        Positioned(
          bottom: 16,
          left: 16,
          child: Row(
            children: [
              _buildDot(Colors.white.withOpacity(0.4)),
              const SizedBox(width: 4),
              _buildDot(Colors.white.withOpacity(0.6)),
              const SizedBox(width: 4),
              _buildDot(Colors.white.withOpacity(0.8)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildNoImageHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.article_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: widget.story.image != null
            ? const BorderRadius.vertical(top: Radius.circular(24))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content card
          Container(
            margin: const EdgeInsets.all(AppSizes.lg),
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
                // Title with accent
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 28,
                      margin: const EdgeInsets.only(right: AppSizes.sm, top: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.story.title,
                        style: TextStyle(
                          fontSize: AppSizes.fontXxl,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.lg),

                // Author Info Card
                _buildAuthorCard(),

                const SizedBox(height: AppSizes.lg),

                // Decorative divider
                _buildDecorativeDivider(),

                const SizedBox(height: AppSizes.lg),

                // Content
                Text(
                  widget.story.content,
                  style: TextStyle(
                    fontSize: AppSizes.fontMd + 1,
                    color: AppColors.onSurface.withOpacity(0.9),
                    height: 1.8,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),

          // Stats card
          _buildStatsCard(),

          // Related section placeholder
          _buildRelatedSection(),

          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildAuthorCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Avatar with gradient border
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.6)],
              ),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.surface,
              child: Text(
                (widget.story.user?.name ?? 'U').substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),

          // Author info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.story.user?.name ?? 'Unknown',
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AppColors.onSurfaceVariant.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.story.formattedDate,
                      style: TextStyle(
                        fontSize: AppSizes.fontSm,
                        color: AppColors.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // New badge if applicable
          if (_isNewStory())
            Container(
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
        ],
      ),
    );
  }

  Widget _buildDecorativeDivider() {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.4),
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
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.outline.withOpacity(0.1),
                  AppColors.outline.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
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
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.visibility_outlined,
            value: '0',
            label: 'Dilihat',
            color: Colors.blue,
          ),
          _buildStatDivider(),
          _buildStatItem(
            icon: Icons.favorite_outline_rounded,
            value: '0',
            label: 'Disukai',
            color: Colors.red,
          ),
          _buildStatDivider(),
          _buildStatItem(
            icon: Icons.access_time_rounded,
            value: '${_calculateReadTime()}',
            label: 'Min baca',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.fontXs,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.outline.withOpacity(0.1),
    );
  }

  Widget _buildRelatedSection() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Cerita Lainnya',
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outline.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.explore_outlined,
                  color: AppColors.onSurfaceVariant.withOpacity(0.5),
                  size: 32,
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Text(
                    'Jelajahi lebih banyak cerita menarik lainnya di halaman utama',
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSizes.lg,
        right: AppSizes.lg,
        bottom: MediaQuery.of(context).padding.bottom + AppSizes.md,
        top: AppSizes.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.95),
        border: Border(
          top: BorderSide(color: AppColors.outline.withOpacity(0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Edit Button
          Expanded(
            child: _buildActionButton(
              icon: Icons.edit_rounded,
              label: 'Edit',
              color: AppColors.primary,
              isOutlined: true,
              onTap: () async {
                HapticFeedback.lightImpact();
                final result = await context.push(
                  EditStoryPage(story: widget.story),
                );
                if (result == true && context.mounted) {
                  context.pop(true);
                }
              },
            ),
          ),
          const SizedBox(width: AppSizes.md),

          // Delete Button
          Expanded(
            child: BlocBuilder<DeleteStoryBloc, DeleteStoryState>(
              builder: (context, state) {
                final isLoading = state.maybeWhen(
                  loading: () => true,
                  orElse: () => false,
                );

                return _buildActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: isLoading ? 'Menghapus...' : 'Hapus',
                  color: AppColors.error,
                  isOutlined: false,
                  isLoading: isLoading,
                  onTap: isLoading ? null : () => _showDeleteConfirmation(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isOutlined,
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withOpacity(isOutlined ? 0.5 : 0),
              width: 1.5,
            ),
            boxShadow: isOutlined
                ? []
                : [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                Icon(icon, size: 18, color: isOutlined ? color : Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w600,
                  color: isOutlined ? color : Colors.white,
                ),
              ),
            ],
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        const Text(
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
