import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_story/presentation/story/blocs/get_stories/get_stories_event_bloc.dart';
import '../../../core/components/empty_state.dart';
import '../../../core/components/error_state.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../auth/blocs/logout/logout_bloc.dart';
import '../../auth/pages/login_page.dart';
import '../../profile/pages/profile_page.dart';
import '../blocs/delete_story/delete_story_bloc.dart';
import '../widgets/story_card.dart';
import 'add_story_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadStories();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadStories() {
    context.read<GetStoriesBloc>().add(
      const GetStoriesEvent.getMyStories(refresh: true),
    );
  }

  void _onScroll() {
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
    return MultiBlocListener(
      listeners: [
        // Logout Listener
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
        // Delete Story Listener
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
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: AppColors.primary,
              size: AppSizes.iconMd,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          const Text(
            'Story App',
            style: TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: AppSizes.fontXl,
            ),
          ),
        ],
      ),
      actions: [
        // Profile Button
        IconButton(
          icon: const Icon(Icons.person_outline, color: AppColors.onSurface),
          onPressed: () {
            context.push(const ProfilePage());
          },
          tooltip: 'Profile',
        ),
        // Logout Button
        BlocBuilder<LogoutBloc, LogoutState>(
          builder: (context, state) {
            final isLoading = state.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );

            return IconButton(
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout, color: AppColors.onSurface),
              onPressed: isLoading ? null : _confirmLogout,
              tooltip: 'Logout',
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return BlocBuilder<GetStoriesBloc, GetStoriesState>(
      builder: (context, state) {
        return state.when(
          initial: () => const LoadingIndicator(),
          loading: () => const LoadingIndicator(message: 'Memuat cerita...'),
          success: (stories, currentPage, lastPage, hasMore, isLoadingMore) {
            if (stories.isEmpty) {
              return EmptyState(
                icon: Icons.article_outlined,
                title: 'Belum Ada Cerita',
                subtitle: 'Mulai bagikan cerita pertamamu!',
                buttonText: 'Buat Cerita',
                onButtonPressed: () async {
                  final result = await context.push(const AddStoryPage());
                  if (result == true) {
                    _loadStories();
                  }
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadStories();
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSizes.md),
                itemCount: stories.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= stories.length) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSizes.md),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final story = stories[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.md),
                    child: StoryCard(story: story, onRefresh: _loadStories),
                  );
                },
              ),
            );
          },
          error: (message) =>
              ErrorState(message: message, onRetry: _loadStories),
        );
      },
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () async {
        final result = await context.push(const AddStoryPage());
        if (result == true) {
          _loadStories();
        }
      },
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      icon: const Icon(Icons.add),
      label: const Text('Cerita Baru'),
    );
  }
}
