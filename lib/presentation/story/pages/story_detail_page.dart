import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_story/core/constants/variables.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../data/models/story_model.dart';
import '../blocs/delete_story/delete_story_bloc.dart';
import 'edit_story_page.dart';

class StoryDetailPage extends StatelessWidget {
  final StoryModel story;

  const StoryDetailPage({super.key, required this.story});

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
        body: CustomScrollView(
          slivers: [
            // App Bar with Image
            _buildSliverAppBar(context),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      story.title,
                      style: const TextStyle(
                        fontSize: AppSizes.fontXxl,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Author Info
                    _buildAuthorInfo(),
                    const SizedBox(height: AppSizes.lg),

                    // Divider
                    Divider(color: AppColors.divider),
                    const SizedBox(height: AppSizes.lg),

                    // Content
                    Text(
                      story.content,
                      style: const TextStyle(
                        fontSize: AppSizes.fontLg,
                        color: AppColors.onSurface,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: story.image != null ? 300 : 0,
      pinned: true,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      flexibleSpace: story.image != null
          ? FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: story.image != null
                    ? '${Variables.baseUrl}/storage/${story.image}'
                    : '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(
                    Icons.broken_image,
                    size: 64,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildAuthorInfo() {
    // print('DEBUG: story.user = ${story.user}');
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryContainer,
          child: Text(
            (story.user?.name ?? 'U').substring(0, 1).toUpperCase(),
            style: const TextStyle(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                story.user?.name ?? 'Unknown',
                style: const TextStyle(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                story.formattedDate,
                style: const TextStyle(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSizes.md,
        right: AppSizes.md,
        bottom: context.padding.bottom + AppSizes.md,
        top: AppSizes.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
            child: OutlinedButton.icon(
              onPressed: () async {
                final result = await context.push(EditStoryPage(story: story));
                if (result == true && context.mounted) {
                  context.pop(true);
                }
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                side: const BorderSide(color: AppColors.primary),
              ),
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

                return FilledButton.icon(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final confirm = await context.showConfirmDialog(
                            title: 'Hapus Cerita',
                            message:
                                'Apakah anda yakin ingin menghapus cerita ini?',
                            confirmText: 'Hapus',
                            confirmColor: AppColors.error,
                          );

                          if (confirm == true && context.mounted) {
                            context.read<DeleteStoryBloc>().add(
                              DeleteStoryEvent.delete(story.id),
                            );
                          }
                        },
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.delete_outline),
                  label: const Text('Hapus'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
