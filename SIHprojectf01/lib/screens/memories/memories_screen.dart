import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// MemoriesScreen — trip memory board, dark "accent panel" theme.
/// Layout unchanged: a scrolling list of photo cards with title, time,
/// location and note.
class MemoriesScreen extends StatelessWidget {
  final String tripId;
  const MemoriesScreen({super.key, this.tripId = ''});

  @override
  Widget build(BuildContext context) {
    final memories = [
      {
        'title': 'Sunset at Promenade',
        'location': 'Sunset Lookout Viewpoint',
        'time': '5:45 PM',
        'note': 'Spectacular golden hour glow across the rocky cliff. Great group photo!',
        'image': 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?w=800',
      },
      {
        'title': 'Coffee & Fresh Sourdough',
        'location': 'Artisan Heritage Roastery',
        'time': '10:30 AM',
        'note': 'Amazing local single-origin pour-over and cinnamon rolls.',
        'image': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800',
      },
    ];

    return Scaffold(
      appBar: TripSafeAppBar(
        title: 'Memories',
        subtitle: '${memories.length} moments logged',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Photo moment added to memories board'),
                      ),
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_a_photo_outlined,
                      size: 17,
                      color: AppTheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        itemCount: memories.length,
        itemBuilder: (context, index) {
          final m = memories[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 186,
                    width: double.infinity,
                    child: Image.network(
                      m['image']!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null ? child : const _PhotoPlaceholder(),
                      errorBuilder: (context, error, stackTrace) =>
                          const _PhotoPlaceholder(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                m['title']!,
                                style: AppTypography.titleMedium,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              m['time']!,
                              style: AppTypography.caption.copyWith(
                                fontSize: 10.5,
                                color: AppTheme.muted(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.place,
                              size: 13,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                m['location']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.chipLabel.copyWith(
                                  color: AppTheme.primary,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          m['note']!,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 12.5,
                            color: AppTheme.body(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Striped placeholder shown while a memory photo loads or fails.
class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF24282C),
      alignment: Alignment.center,
      child: Icon(
        Icons.photo_outlined,
        size: 34,
        color: AppTheme.muted(context),
      ),
    );
  }
}
