import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../utils/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';

/// DestinationDetailScreen — Overview of a target destination / travel circuit (Step 1)
class DestinationDetailScreen extends StatelessWidget {
  final String destinationId;
  const DestinationDetailScreen({super.key, required this.destinationId});

  @override
  Widget build(BuildContext context) {
    final destTitle = destinationId.isNotEmpty ? destinationId : 'Kozhikode & Coastal Circuit';

    return Scaffold(
      appBar: AppBar(
        title: Text(destTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(destTitle, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('South India Coastal Heritage & Sunset Promenade', style: TextStyle(color: AppTheme.mutedDark)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Safety Score: 92/100', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Avg: ₹2,000 / day', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Highlights & Must-See Spots', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('• Sunset Sea Cliff Promenade & Beach Walk'),
            const Text('• Central Botanical Gardens & Arboretum'),
            const Text('• Artisan Heritage Bakery & Single-Origin Roastery'),
            const Text('• Regional Maritime & Cultural History Museum'),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Plan Trip to $destTitle',
              icon: Icons.route,
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.plan,
                arguments: {RouteArgs.destinationId: destTitle},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
