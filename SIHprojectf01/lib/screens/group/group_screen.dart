import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/trip_plan.dart';
import '../../services/trip_planning_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// GroupScreen — trip members, invite code sharing, and joining a trip.
///
/// Local/demo mode: there is no live backend, so "joining" simulates
/// matching against the single active local trip rather than connecting
/// to a real trip on another device. This is clearly labeled in the UI.
class GroupScreen extends StatefulWidget {
  final String tripId;
  const GroupScreen({super.key, this.tripId = ''});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final _planningService = TripPlanningService.instance;
  final _joinCodeController = TextEditingController();

  @override
  void dispose() {
    _joinCodeController.dispose();
    super.dispose();
  }

  void _copyInviteCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite code copied!')),
    );
  }

  void _attemptJoin(TripPlan trip) {
    final entered = _joinCodeController.text.trim().toUpperCase();
    if (entered.isEmpty) return;

    final matches = entered == trip.inviteCode.toUpperCase();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: matches ? AppTheme.success : null,
        content: Text(
          matches
              ? "This matches your current trip — you're already in!"
              : 'Trip code not found in demo mode. TripSafe currently '
                  'supports one active local trip per device.',
        ),
      ),
    );
    if (matches) {
      _joinCodeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Group')),
      body: AnimatedBuilder(
        animation: _planningService,
        builder: (context, _) {
          final trip = _planningService.activeTrip;

          if (trip == null) {
            return const EmptyState(
              message: 'No active trip yet.\nPlan a trip to start a group.',
              icon: Icons.group_outlined,
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Members',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  child: Column(
                    children: [
                      for (int i = 0; i < trip.members.length; i++) ...[
                        if (i > 0) Divider(color: Colors.grey.shade200),
                        _buildMemberRow(trip.members[i]),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  'Invite Code',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  onTap: () => _copyInviteCode(trip.inviteCode),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.inviteCode,
                              style: AppTypography.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              'Share this code so others can join your trip',
                              style: AppTypography.caption.copyWith(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.copy_outlined, color: AppTheme.primary, size: 20),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  'Join a Trip',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppTheme.secondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Demo Mode — joining simulates matching your local trip. '
                          'Real multi-device sync requires a connected backend.',
                          style: AppTypography.caption.copyWith(color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _joinCodeController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          hintText: 'Enter invite code',
                        ),
                        onSubmitted: (_) => _attemptJoin(trip),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton(
                      onPressed: () => _attemptJoin(trip),
                      child: const Text('Join'),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMemberRow(GroupMember member) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
            child: Text(
              member.avatarInitials ?? '?',
              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              member.name,
              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              member.role,
              style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
