import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// MemoriesScreen — Captured trip moments, photos, and notes (Step 9)
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
      appBar: AppBar(
        title: const Text('Trip Memories & Photos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Photo moment added to memories board!')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: memories.length,
        itemBuilder: (context, index) {
          final m = memories[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      child: Image.network(
                        m['image']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.photo, size: 48, color: AppTheme.primary),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(m['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(m['time']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        Text('📍 ${m['location']}', style: const TextStyle(fontSize: 12, color: AppTheme.primary)),
                        const SizedBox(height: 6),
                        Text(m['note']!, style: const TextStyle(fontSize: 12, color: Colors.black87)),
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
