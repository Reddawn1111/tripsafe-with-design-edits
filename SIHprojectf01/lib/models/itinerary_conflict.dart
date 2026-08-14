enum ItineraryConflictSeverity { warning, info }

/// A detected scheduling issue for a stop, surfaced as a banner in the
/// itinerary UI. Only raised for stops the user has manually pinned a
/// time on — the auto-generated schedule is always internally consistent.
class ItineraryConflict {
  final String stopId;
  final String message;
  final ItineraryConflictSeverity severity;

  const ItineraryConflict({
    required this.stopId,
    required this.message,
    required this.severity,
  });
}
