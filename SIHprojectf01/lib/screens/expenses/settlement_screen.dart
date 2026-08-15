import 'package:flutter/material.dart';
import '../../models/trip_plan.dart';
import '../../services/group_trip_service.dart';
import '../../services/trip_planning_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// SettlementScreen — Minimalist debt simplification and settlement breakdown (Step 9)
class SettlementScreen extends StatelessWidget {
  final String tripId;
  const SettlementScreen({super.key, this.tripId = ''});

  @override
  Widget build(BuildContext context) {
    final groupService = GroupTripService.instance;
    final activeTrip = TripPlanningService.instance.activeTrip;
    final members = activeTrip?.members ?? [
      GroupMember(id: 'mem_1', name: 'You (Organizer)'),
      GroupMember(id: 'mem_2', name: 'Aarav'),
      GroupMember(id: 'mem_3', name: 'Ananya'),
    ];

    final settlements = groupService.calculateSettlements(members);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Settlement Summary'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.handshake_outlined, color: AppTheme.secondary, size: 28),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fair Split Calculation', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          'Debts are simplified so each friend makes the minimum number of direct transfers.',
                          style: TextStyle(fontSize: 12, color: AppTheme.mutedDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Recommended Settlements',
              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (settlements.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: Text('All group expenses are completely balanced!')),
              )
            else
              ...settlements.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.red.shade100,
                          child: const Icon(Icons.arrow_forward, color: AppTheme.danger, size: 18),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${s.fromMemberName} pays ${s.toMemberName}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Text('Direct peer-to-peer settlement', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
                            ],
                          ),
                        ),
                        Text(
                          '₹${s.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
              icon: const Icon(Icons.share),
              label: const Text('Share Settlement Breakdown with Group'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settlement breakdown link copied to clipboard!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
