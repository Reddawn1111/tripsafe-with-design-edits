import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// AlternativeDestinationScreen — Browse safe alternative tourist destinations (Step 17)
class AlternativeDestinationScreen extends StatelessWidget {
  final String tripId;
  final String alertId;

  const AlternativeDestinationScreen({
    super.key,
    this.tripId = '',
    this.alertId = '',
  });

  @override
  Widget build(BuildContext context) {
    final alternatives = [
      {
        'name': 'Wayanad Hill & Plantation Circuit',
        'state': 'Kerala',
        'safety': 'Safe (Score 94)',
        'vibe': 'Mist, tea estates & spice trails',
        'cost': '₹2,200/day',
        'highlights': 'Banasura Sagar, Chembra Peak View, Edakkal Caves',
      },
      {
        'name': 'Mysuru Heritage & Palace Route',
        'state': 'Karnataka',
        'safety': 'Safe (Score 96)',
        'vibe': 'Royal architecture, silk & gardens',
        'cost': '₹1,800/day',
        'highlights': 'Mysore Palace, Chamundi Hill, Brindavan Gardens',
      },
      {
        'name': 'Coorg Coffee Country & River Trails',
        'state': 'Karnataka',
        'safety': 'Safe (Score 91)',
        'vibe': 'Nature walks, waterfalls & homestays',
        'cost': '₹2,500/day',
        'highlights': 'Abbey Falls, Raja’s Seat, Dubare Camp',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alternative Destinations'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: alternatives.length,
        itemBuilder: (context, index) {
          final dest = alternatives[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dest['name']!,
                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          dest['safety']!,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.success),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(dest['vibe']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Highlights: ${dest['highlights']}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Est. Cost: ${dest['cost']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.plan,
                            arguments: {RouteArgs.destinationId: dest['name']},
                          );
                        },
                        child: const Text('Select Destination', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
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
