import '../models/itinerary_conflict.dart';
import '../models/trip_plan.dart';

/// Detects scheduling conflicts introduced by a user's manual "change time"
/// edit (a pinned stop start time). The auto-generated schedule is always
/// internally consistent (stops are packed back-to-back with no gap), so
/// only pinned stops are checked — that's the only place a conflict can
/// actually arise.
class ItineraryConflictService {
  static const int _tightTransitionBufferMinutes = 5;

  List<ItineraryConflict> detectConflicts(DayPlan day) {
    final conflicts = <ItineraryConflict>[];
    final activeStops = day.stops.where((s) => !s.isSkipped).toList();

    for (int i = 1; i < activeStops.length; i++) {
      final current = activeStops[i];
      final pinnedTime = current.pinnedStartTime;
      if (pinnedTime == null) continue;

      final prev = activeStops[i - 1];
      final prevEnd = _parseClockTime(prev.endTime);
      final pinned = _parseClockTime(pinnedTime);
      if (prevEnd == null || pinned == null) continue;

      final impliedArrival =
          prevEnd.add(Duration(minutes: current.travelTimeFromPreviousMinutes));
      final bufferMinutes = pinned.difference(impliedArrival).inMinutes;

      if (bufferMinutes < 0) {
        conflicts.add(
          ItineraryConflict(
            stopId: current.id,
            message:
                'Not enough time between stops — you may arrive after your '
                'planned start time for ${current.place.name}.',
            severity: ItineraryConflictSeverity.warning,
          ),
        );
      } else if (bufferMinutes < _tightTransitionBufferMinutes) {
        conflicts.add(
          ItineraryConflict(
            stopId: current.id,
            message:
                'Tight transition — only $bufferMinutes min between stops '
                'before ${current.place.name}.',
            severity: ItineraryConflictSeverity.info,
          ),
        );
      }
    }

    return conflicts;
  }

  DateTime? _parseClockTime(String text) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false)
        .firstMatch(text.trim());
    if (match == null) return null;

    int hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();

    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return DateTime(2000, 1, 1, hour, minute);
  }
}
