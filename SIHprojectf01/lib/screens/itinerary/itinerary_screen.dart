import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/itinerary_conflict.dart';
import '../../models/trip_plan.dart';
import '../../services/itinerary_conflict_service.dart';
import '../../services/trip_planning_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';
import 'add_stop_sheet.dart';

/// ItineraryScreen — trip itinerary and route editing, dark "accent panel"
/// theme. All editing behaviour is unchanged: reorder, edit time, change
/// place, insert, skip, delete.
class ItineraryScreen extends StatelessWidget {
  final String tripId;
  const ItineraryScreen({super.key, this.tripId = ''});

  static final _conflictService = ItineraryConflictService();

  @override
  Widget build(BuildContext context) {
    final planningService = TripPlanningService.instance;

    return Scaffold(
      appBar: TripSafeAppBar(
        title: 'Itinerary',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar),
            tooltip: 'Edit Plan Parameters',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.plan),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: planningService,
        builder: (context, _) {
          final trip = planningService.activeTrip;

          if (trip == null || trip.days.isEmpty || trip.totalStopsCount == 0) {
            return EmptyState(
              message:
                  'Your trip itinerary is empty.\nExplore nearby places or generate a budget plan.',
              icon: Icons.map_outlined,
              actionLabel: 'Explore nearby places',
              action: () => Navigator.of(context).pushNamed(AppRoutes.discover),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTripHeader(context, trip),
                const SizedBox(height: 18),
                ...trip.days.asMap().entries.map((entry) {
                  final dIdx = entry.key;
                  final day = entry.value;
                  return _buildDayCard(
                    context,
                    planningService,
                    trip,
                    day,
                    dIdx,
                  );
                }),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: 'Start active journey',
                  icon: Icons.navigation_outlined,
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.journey),
                ),
                const SizedBox(height: 11),
                SecondaryButton(
                  label: 'View group & invite code',
                  icon: Icons.group_outlined,
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.group),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Trip header — the rust accent panel ────────────────────────────────
  Widget _buildTripHeader(BuildContext context, TripPlan trip) {
    const ink = AppTheme.onPrimary;
    final within = trip.remainingBudget >= 0;

    return AccentPanel(
      color: AppTheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  trip.title.toUpperCase(),
                  style: AppTypography.displayMedium.copyWith(
                    color: ink,
                    fontSize: 25,
                    height: 1.02,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: const BoxDecoration(
                  color: ink,
                  borderRadius: AppSpacing.pill,
                ),
                child: Text(
                  trip.inviteCode,
                  style: AppTypography.chipLabel.copyWith(
                    color: AppTheme.primary,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${trip.destinationName} · ${trip.days.length} days · ${trip.members.length} travellers',
            style: AppTypography.chipLabel.copyWith(
              color: ink.withValues(alpha: 0.75),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _panelStat('Stops', '${trip.totalStopsCount}'),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _panelStat('Budget', '₹${trip.totalBudget.round()}'),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _panelStat(
                  'Planned',
                  '₹${trip.totalSpentOrPlanned.round()}',
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _panelStat(
                  'Left',
                  '₹${trip.remainingBudget.round()}',
                  dark: true,
                  valueColor: within
                      ? const Color(0xFF5FD48F)
                      : const Color(0xFFFF8A6B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _panelStat(
    String label,
    String value, {
    bool dark = false,
    Color? valueColor,
  }) {
    const ink = AppTheme.onPrimary;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: dark ? ink : ink.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.titleMedium.copyWith(
              color: valueColor ?? ink,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: AppTypography.chipLabel.copyWith(
              fontSize: 8.5,
              letterSpacing: 0.9,
              color: dark
                  ? const Color(0x99F2F0EA)
                  : ink.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }

  // ── Day card ───────────────────────────────────────────────────────────
  Widget _buildDayCard(
    BuildContext context,
    TripPlanningService service,
    TripPlan trip,
    DayPlan day,
    int dIdx,
  ) {
    final conflicts = _conflictService.detectConflicts(day);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    '${dIdx + 1}',
                    style: AppTypography.chipLabel.copyWith(
                      color: AppTheme.onPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleSmall.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${day.stops.length} stops',
                        style: AppTypography.caption.copyWith(
                          fontSize: 10.5,
                          color: AppTheme.muted(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PillButton(
                  label: 'Optimize',
                  icon: Icons.route,
                  dense: true,
                  color: AppTheme.secondary,
                  onPressed: () {
                    service.optimizeDayRoute(dIdx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Route optimized for minimal travel time'),
                      ),
                    );
                  },
                ),
              ],
            ),

            if (conflicts.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildConflictBanner(context, conflicts),
            ],

            const SizedBox(height: 14),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: day.stops.length,
              onReorder: (oldIndex, newIndex) =>
                  service.reorderStops(dIdx, oldIndex, newIndex),
              itemBuilder: (context, sIdx) {
                final stop = day.stops[sIdx];
                final isFirst = sIdx == 0;
                final struck = stop.isVisited || stop.isSkipped;

                return Padding(
                  key: ValueKey(stop.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isFirst)
                        Padding(
                          padding: const EdgeInsets.only(left: 6, bottom: 9),
                          child: Row(
                            children: [
                              Icon(
                                Icons.directions_car,
                                size: 13,
                                color: AppTheme.muted(context),
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  '${stop.distanceFromPreviousKm.toStringAsFixed(1)} km · ~${stop.travelTimeFromPreviousMinutes} min transit',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 11,
                                    color: AppTheme.muted(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          // Time gutter + status dot
                          SizedBox(
                            width: 44,
                            child: Column(
                              children: [
                                Text(
                                  stop.startTime,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.chipLabel.copyWith(
                                    fontSize: 10.5,
                                    color: stop.isSkipped
                                        ? AppTheme.muted(context)
                                        : AppTheme.onDark,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: stop.isVisited
                                        ? AppTheme.success
                                        : stop.isSkipped
                                            ? Colors.transparent
                                            : AppTheme.primary,
                                    border: stop.isSkipped
                                        ? Border.all(
                                            color: AppTheme.muted(context),
                                            width: 1.5,
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 7,
                                  runSpacing: 5,
                                  children: [
                                    Text(
                                      stop.place.name,
                                      style: AppTypography.titleSmall.copyWith(
                                        fontSize: 14,
                                        color: struck
                                            ? AppTheme.muted(context)
                                            : AppTheme.onDark,
                                        decoration: struck
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    if (stop.isSkipped)
                                      StatusPill(
                                        label: 'Skipped',
                                        color: AppTheme.mutedDark,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${stop.startTime} – ${stop.endTime} · ${stop.estimatedDurationMinutes}m visit',
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 11,
                                    color: AppTheme.muted(context),
                                  ),
                                ),
                                if (stop.optimizationHint != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      stop.optimizationHint!,
                                      style: AppTypography.caption.copyWith(
                                        fontSize: 10.5,
                                        color: AppTheme.warning,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            stop.estimatedCost > 0
                                ? '₹${stop.estimatedCost.round()}'
                                : 'Free',
                            style: AppTypography.chipLabel.copyWith(
                              fontSize: 11.5,
                              color: stop.estimatedCost > 0
                                  ? AppTheme.onDark
                                  : AppTheme.success,
                            ),
                          ),
                          _buildStopMenu(context, service, trip, dIdx, sIdx, stop),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            GestureDetector(
              onTap: () => _addStop(context, service, trip, dIdx),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  borderRadius: AppSpacing.pill,
                  border: Border.all(
                    color: const Color(0x2EFFFFFF),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 15, color: AppTheme.muted(context)),
                    const SizedBox(width: 7),
                    Text(
                      'Add stop',
                      style: AppTypography.chipLabel.copyWith(
                        fontSize: 12,
                        color: AppTheme.muted(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictBanner(
    BuildContext context,
    List<ItineraryConflict> conflicts,
  ) {
    final shown = conflicts.take(2).toList();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.tint(AppTheme.warning, 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${conflicts.length} timing ${conflicts.length == 1 ? 'conflict' : 'conflicts'}',
            style: AppTypography.chipLabel.copyWith(
              fontSize: 11.5,
              color: AppTheme.warning,
            ),
          ),
          const SizedBox(height: 5),
          for (final conflict in shown)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 13,
                    color: AppTheme.warning,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      conflict.message,
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        color: AppTheme.body(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStopMenu(
    BuildContext context,
    TripPlanningService service,
    TripPlan trip,
    int dIdx,
    int sIdx,
    StopItem stop,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18),
      onSelected: (value) async {
        switch (value) {
          case 'edit_time':
            await _editStopTime(context, service, dIdx, stop);
            break;
          case 'change_place':
            await _changePlace(context, service, trip, dIdx, stop);
            break;
          case 'insert_after':
            await _addStop(context, service, trip, dIdx, insertAfterIndex: sIdx);
            break;
          case 'toggle_skip':
            service.toggleSkipStop(dIdx, stop.id);
            break;
          case 'delete':
            service.removeStop(dIdx, stop.id);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit_time', child: Text('Edit time')),
        const PopupMenuItem(value: 'change_place', child: Text('Change place')),
        const PopupMenuItem(value: 'insert_after', child: Text('Insert stop after')),
        PopupMenuItem(
          value: 'toggle_skip',
          child: Text(stop.isSkipped ? 'Unskip' : 'Skip'),
        ),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }

  Future<void> _editStopTime(
    BuildContext context,
    TripPlanningService service,
    int dIdx,
    StopItem stop,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Set start time for ${stop.place.name}',
    );
    if (picked == null) return;

    final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
    final minute = picked.minute.toString().padLeft(2, '0');
    final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
    service.updateStopStartTime(dIdx, stop.id, '$hour:$minute $period');
  }

  Future<void> _changePlace(
    BuildContext context,
    TripPlanningService service,
    TripPlan trip,
    int dIdx,
    StopItem stop,
  ) async {
    final newPlace = await AddStopSheet.show(
      context,
      latitude: trip.destinationLat,
      longitude: trip.destinationLng,
      title: 'Change to...',
    );
    if (newPlace == null) return;
    service.replaceStopPlace(dIdx, stop.id, newPlace);
  }

  Future<void> _addStop(
    BuildContext context,
    TripPlanningService service,
    TripPlan trip,
    int dIdx, {
    int? insertAfterIndex,
  }) async {
    final place = await AddStopSheet.show(
      context,
      latitude: trip.destinationLat,
      longitude: trip.destinationLng,
    );
    if (place == null) return;

    final day = trip.days[dIdx];
    final position =
        insertAfterIndex != null ? insertAfterIndex + 1 : day.stops.length;
    service.insertStopAt(dIdx, position, place);
  }
}
