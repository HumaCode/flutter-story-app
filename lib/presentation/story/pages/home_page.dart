import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_story/presentation/splash/widgets/animated_background.dart';
import '../../../core/components/empty_state.dart';
import '../../../core/components/error_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../auth/blocs/logout/logout_bloc.dart';
import '../../auth/pages/login_page.dart';
import '../../profile/pages/profile_page.dart';
import '../blocs/delete_story/delete_story_bloc.dart';
import '../blocs/get_stories/get_stories_event_bloc.dart';
import '../widgets/story_card.dart';
import 'add_story_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  // Animation Controllers
  late AnimationController _headerController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;

  // Untuk efek parallax header
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _loadStories();
    _scrollController.addListener(_onScroll);
    _initAnimations();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _headerController,
            curve: Curves.easeOutCubic,
          ),
        );

    _headerController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  void _loadStories() {
    context.read<GetStoriesBloc>().add(
      const GetStoriesEvent.getMyStories(refresh: true),
    );
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });

    if (_isBottom) {
      context.read<GetStoriesBloc>().add(const GetStoriesEvent.loadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _confirmLogout() async {
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLogoutBottomSheet(),
    );

    if (confirm == true && mounted) {
      context.read<LogoutBloc>().add(const LogoutEvent.logout());
    }
  }

  Widget _buildLogoutBottomSheet() {
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

          // Icon
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.logout_rounded, color: AppColors.error, size: 32),
          ),
          const SizedBox(height: AppSizes.md),

          // Title
          Text(
            'Logout',
            style: TextStyle(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.sm),

          // Message
          Text(
            'Apakah anda yakin ingin keluar dari akun?',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
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
                    side: BorderSide(color: AppColors.outline.withOpacity(0.3)),
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
                  child: const Text(
                    'Logout',
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LogoutBloc, LogoutState>(
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
        ),
        BlocListener<DeleteStoryBloc, DeleteStoryState>(
          listener: (context, state) {
            state.maybeWhen(
              success: (message) {
                context.showSuccess(message);
                _loadStories();
              },
              error: (message) {
                context.showError(message);
              },
              orElse: () {},
            );
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // ═══════════════════════════════════════════
            // ANIMATED BACKGROUND
            // ═══════════════════════════════════════════
            const AnimatedBackground(circleCount: 15, isDarkMode: false),

            // ═══════════════════════════════════════════
            // MAIN CONTENT
            // ═══════════════════════════════════════════
            SafeArea(
              child: Column(
                children: [
                  // Custom Header
                  _buildHeader(),

                  // Body Content
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  Widget _buildHeader() {
    // Hitung collapse progress (0 = fully expanded, 1 = collapsed)
    final double collapseProgress = (_scrollOffset / 120).clamp(0.0, 1.0);

    // Stats card animation values
    final double statsOpacity = (1 - collapseProgress * 1.5).clamp(0.0, 1.0);

    return FadeTransition(
      opacity: _headerFadeAnimation,
      child: SlideTransition(
        position: _headerSlideAnimation,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.md,
            AppSizes.lg,
            0,
          ),
          decoration: BoxDecoration(
            // Tambah background saat scroll untuk efek elevation
            color: collapseProgress > 0.3
                ? AppColors.surface.withOpacity(0.95)
                : Colors.transparent,
            boxShadow: collapseProgress > 0.3
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row - Logo & Actions (selalu terlihat)
              Row(
                children: [
                  // Logo & Title
                  Expanded(
                    child: Row(
                      children: [
                        // Animated Logo
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1000),
                          builder: (context, value, child) {
                            return Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(
                                      0.3 * value,
                                    ),
                                    blurRadius: 12 * value,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.auto_stories_rounded,
                                color: AppColors.onPrimary,
                                size: 22,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: AppSizes.md),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Story App',
                                style: TextStyle(
                                  fontSize: AppSizes.fontXl,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onBackground,
                                ),
                              ),
                              // Subtitle hilang saat collapse
                              if (collapseProgress < 0.5)
                                Text(
                                  'Bagikan ceritamu ✨',
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
                  ),

                  // Action Buttons
                  Row(
                    children: [
                      // Profile Button
                      _buildHeaderButton(
                        icon: Icons.person_outline_rounded,
                        onTap: () => context.push(const ProfilePage()),
                        tooltip: 'Profile',
                      ),
                      const SizedBox(width: AppSizes.sm),

                      // Logout Button
                      BlocBuilder<LogoutBloc, LogoutState>(
                        builder: (context, state) {
                          final isLoading = state.maybeWhen(
                            loading: () => true,
                            orElse: () => false,
                          );

                          return _buildHeaderButton(
                            icon: Icons.logout_rounded,
                            onTap: isLoading ? null : _confirmLogout,
                            tooltip: 'Logout',
                            isLoading: isLoading,
                            isDestructive: true,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              // Stats Card dengan animasi collapse - pakai ClipRect
              ClipRect(
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.topCenter,
                  heightFactor: 1 - collapseProgress,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: statsOpacity,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: AppSizes.md,
                        bottom: AppSizes.md,
                      ),
                      child: _buildStatsCard(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback? onTap,
    required String tooltip,
    bool isLoading = false,
    bool isDestructive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDestructive
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDestructive
                    ? AppColors.error.withOpacity(0.2)
                    : AppColors.outline.withOpacity(0.1),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.error,
                    ),
                  )
                : Icon(
                    icon,
                    color: isDestructive
                        ? AppColors.error
                        : AppColors.onSurfaceVariant,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return BlocBuilder<GetStoriesBloc, GetStoriesState>(
      builder: (context, state) {
        int storyCount = 0;
        state.maybeWhen(
          success: (stories, _, __, ___, ____) {
            storyCount = stories.length;
          },
          orElse: () {},
        );

        return Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildStatItem(
                icon: Icons.article_outlined,
                value: storyCount.toString(),
                label: 'Cerita',
                color: AppColors.primary,
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
                icon: Icons.visibility_outlined,
                value: '0',
                label: 'Dilihat',
                color: Colors.blue,
              ),
            ],
          ),
        );
      },
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

  Widget _buildBody() {
    return BlocBuilder<GetStoriesBloc, GetStoriesState>(
      builder: (context, state) {
        return state.when(
          initial: () => _buildLoadingShimmer(),
          loading: () => _buildLoadingShimmer(),
          success: (stories, currentPage, lastPage, hasMore, isLoadingMore) {
            if (stories.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadStories();
              },
              color: AppColors.primary,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  AppSizes.sm,
                  AppSizes.lg,
                  100,
                ),
                itemCount: stories.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= stories.length) {
                    return _buildLoadMoreIndicator();
                  }

                  final story = stories[index];

                  // Staggered animation untuk setiap card
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + (index * 50)),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.md),
                      child: StoryCard(story: story, onRefresh: _loadStories),
                    ),
                  );
                },
              ),
            );
          },
          error: (message) => _buildErrorState(message),
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.lg),
      itemCount: 3,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.3, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Container(
                height: 200,
                margin: const EdgeInsets.only(bottom: AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.outline.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 14,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: AppColors.outline.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 10,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.outline.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.outline.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: MediaQuery.of(context).size.width * 0.6,
                        decoration: BoxDecoration(
                          color: AppColors.outline.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.article_outlined,
                      size: 64,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.lg),

            Text(
              'Belum Ada Cerita',
              style: TextStyle(
                fontSize: AppSizes.fontXl,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            Text(
              'Mulai bagikan cerita pertamamu\ndan biarkan dunia mendengarnya!',
              style: TextStyle(
                fontSize: AppSizes.fontMd,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.xl),

            // Create Button
            ElevatedButton.icon(
              onPressed: () async {
                final result = await context.push(const AddStoryPage());
                if (result == true) {
                  _loadStories();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Buat Cerita Pertama',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            Text(
              'Oops! Terjadi Kesalahan',
              style: TextStyle(
                fontSize: AppSizes.fontXl,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            Text(
              message,
              style: TextStyle(
                fontSize: AppSizes.fontMd,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.xl),

            OutlinedButton.icon(
              onPressed: _loadStories,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(Icons.refresh_rounded, color: AppColors.primary),
              label: Text(
                'Coba Lagi',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Memuat lebih banyak...',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: AppSizes.fontSm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              HapticFeedback.lightImpact();
              final result = await context.push(const AddStoryPage());
              if (result == true) {
                _loadStories();
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: AppColors.onPrimary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Cerita Baru',
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
