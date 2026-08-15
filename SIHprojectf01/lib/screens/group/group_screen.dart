import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/trip_plan.dart';
import '../../services/trip_planning_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/floating_nav_bar.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';

/// GroupScreen — trip members, invite code sharing, joining a trip.
/// Dark "accent panel" theme; the invite code is the accent panel.
///
/// Local/demo mode: there is no live backend, so "joining" simulates
/// matching against the single active local trip.
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
      const SnackBar(content: Text('Invite code copied')),
    );
  }

  void _attemptJoin(TripPlan trip) {
    final entered = _joinCodeController.text.trim().toUpperCase();
    if (entered.isEmpty) return;

    final matches = entered == trip.inviteCode.toUpperCase();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
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
      extendBody: true,
      bottomNavigationBar: const FloatingNavBar(current: NavDestination.group),
      appBar: const TripSafeAppBar(title: 'Trip group'),
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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              104,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Invite code — the accent panel
                AccentPanel(
                  color: AppTheme.primary,
                  onTap: () => _copyInviteCode(trip.inviteCode),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INVITE CODE',
                        style: AppTypography.sectionLabel.copyWith(
                          fontSize: 10.5,
                          letterSpacing: 1.8,
                          color: AppTheme.onPrimary.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              trip.inviteCode,
                              style: AppTypography.displayLarge.copyWith(
                                color: AppTheme.onPrimary,
                                fontSize: 38,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          CircleIconButton(
                            icon: Icons.copy_outlined,
                            size: 36,
                            background: AppTheme.onPrimary,
                            foreground: AppTheme.primary,
                            onPressed: () => _copyInviteCode(trip.inviteCode),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Share this code so others can join your trip',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppTheme.onPrimary.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),
                SectionLabel('Members · ${trip.members.length}'),
                const SizedBox(height: 11),
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 6,
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < trip.members.length; i++) ...[
                        if (i > 0)
                          const Divider(height: 1, color: AppTheme.borderDark),
                        _buildMemberRow(trip.members[i]),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 22),
                const SectionLabel('Join a trip'),
                const SizedBox(height: 11),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.tint(AppTheme.secondary, 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.secondary.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 15,
                        color: AppTheme.secondary,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Demo mode — joining simulates matching your local trip. '
                          'Real multi-device sync requires a connected backend.',
                          style: AppTypography.caption.copyWith(
                            fontSize: 11,
                            color: AppTheme.body(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 11),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _joinCodeController,
                        textCapitalization: TextCapitalization.characters,
                        style: AppTypography.titleSmall,
                        decoration: const InputDecoration(
                          hintText: 'Enter invite code',
                        ),
                        onSubmitted: (_) => _attemptJoin(trip),
                      ),
                    ),
                    const SizedBox(width: 10),
                    PillButton(
                      label: 'Join',
                      onPressed: () => _attemptJoin(trip),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMemberRow(GroupMember member) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.tint(AppTheme.primary),
              shape: BoxShape.circle,
            ),
            child: Text(
              member.avatarInitials ?? '?',
              style: AppTypography.chipLabel.copyWith(
                color: AppTheme.primary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              member.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleSmall,
            ),
          ),
          const SizedBox(width: 8),
          StatusPill(label: member.role, color: AppTheme.mutedDark),
        ],
      ),
    );
  }
}
