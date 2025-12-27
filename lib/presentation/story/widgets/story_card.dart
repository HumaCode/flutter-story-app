import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_story/core/constants/variables.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../data/models/story_model.dart';
import '../blocs/delete_story/delete_story_bloc.dart';
import '../pages/edit_story_page.dart';
import '../pages/story_detail_page.dart';

class StoryCard extends StatelessWidget {
  final StoryModel story;
  final VoidCallback? onRefresh;

  const StoryCard({super.key, required this.story, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final result = await context.push(StoryDetailPage(story: story));
          if (result == true) {
            onRefresh?.call();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            if (story.image != null) _buildImage(),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    story.title,
                    style: const TextStyle(
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.sm),

                  // Content Preview
                  Text(
                    story.content,
                    style: const TextStyle(
                      fontSize: AppSizes.fontMd,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Footer
                  Row(
                    children: [
                      // Author & Date
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.primaryContainer,
                              child: Text(
                                (story.user?.name ?? 'U')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontSize: AppSizes.fontSm,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    story.user?.name ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: AppSizes.fontSm,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    story.formattedDate,
                                    style: const TextStyle(
                                      fontSize: AppSizes.fontXs,
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
                      _buildActionButtons(context),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: CachedNetworkImage(
        imageUrl: story.image != null
            ? '${Variables.baseUrl}/storage/${story.image}'
            : '', // atau bisa pakai placeholder/default image
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.surfaceVariant,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.surfaceVariant,
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: AppColors.onSurfaceVariant,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit Button
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          iconSize: AppSizes.iconSm,
          color: AppColors.primary,
          onPressed: () async {
            final result = await context.push(EditStoryPage(story: story));
            if (result == true) {
              onRefresh?.call();
            }
          },
          tooltip: 'Edit',
        ),

        // Delete Button
        IconButton(
          icon: const Icon(Icons.delete_outline),
          iconSize: AppSizes.iconSm,
          color: AppColors.error,
          onPressed: () async {
            final confirm = await context.showConfirmDialog(
              title: 'Hapus Cerita',
              message: 'Apakah anda yakin ingin menghapus cerita ini?',
              confirmText: 'Hapus',
              confirmColor: AppColors.error,
            );

            if (confirm == true && context.mounted) {
              context.read<DeleteStoryBloc>().add(
                DeleteStoryEvent.delete(story.id),
              );
            }
          },
          tooltip: 'Hapus',
        ),
      ],
    );
  }
}
