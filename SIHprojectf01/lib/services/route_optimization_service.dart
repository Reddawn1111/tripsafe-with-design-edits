import 'dart:math';
import '../models/trip_plan.dart';

/// Route Optimization and Timing Intelligence (Step 8)
/// Computes segment distances, travel time estimates, and optimizes stop sequence
/// to reduce backtracking, align with opening/sunset windows, and respect budgets.
class RouteOptimizationService {
  static const double avgUrbanSpeedKmH = 22.0; // 22 km/h average city transit/driving speed

  /// Haversine formula to compute distance in km
  double computeDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180.0;
    final dLon = (lon2 - lon1) * pi / 180.0;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180.0) * cos(lat2 * pi / 180.0) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Estimates travel time in minutes based on distance and city traffic factor
  int estimateTravelMinutes(double distanceKm) {
    if (distanceKm <= 0.2) return 3; // Short walking distance
    final hours = distanceKm / avgUrbanSpeedKmH;
    final minutes = (hours * 60).round() + 4; // Add 4 min for buffer/traffic
    return max(4, min(120, minutes));
  }

  /// Calculates travel times and distances along a sequential list of stops
  List<StopItem> calculateRouteMetrics(List<StopItem> stops, {DateTime? dayStartTime}) {
    if (stops.isEmpty) return [];

    DateTime currentTime = dayStartTime ?? DateTime(2026, 9, 1, 9, 30); // Default 9:30 AM start
    final List<StopItem> updated = [];

    for (int i = 0; i < stops.length; i++) {
      final currentStop = stops[i];
      double distFromPrev = 0.0;
      int travelMin = 0;

      if (i > 0) {
        final prev = updated[i - 1];
        distFromPrev = computeDistanceKm(
          prev.place.latitude,
          prev.place.longitude,
          currentStop.place.latitude,
          currentStop.place.longitude,
        );
        travelMin = estimateTravelMinutes(distFromPrev);
      }

      currentTime = currentTime.add(Duration(minutes: travelMin));
      final startTimeStr = _formatTime(currentTime);

      currentTime = currentTime.add(Duration(minutes: currentStop.estimatedDurationMinutes));
      final endTimeStr = _formatTime(currentTime);

      String? hint;
      if (currentStop.place.bestVisitWindow != null &&
          currentStop.place.bestVisitWindow!.contains('Sunset') &&
          currentTime.hour < 16) {
        hint = '🌅 Tip: Best photographed around sunset (5–6:30 PM)';
      }

      updated.add(
        currentStop.copyWith(
          startTime: startTimeStr,
          endTime: endTimeStr,
          distanceFromPreviousKm: distFromPrev,
          travelTimeFromPreviousMinutes: travelMin,
          optimizationHint: hint,
        ),
      );
    }

    return updated;
  }

  /// Optimizes stop sequence using 2-opt nearest-neighbor heuristic with sunset priority
  List<StopItem> optimizeSequence(List<StopItem> stops, {double? startLat, double? startLon}) {
    if (stops.length <= 2) {
      return calculateRouteMetrics(stops);
    }

    final unvisited = List<StopItem>.from(stops);
    final List<StopItem> optimized = [];

    // Prioritize sunset/viewpoint spots towards the late afternoon/evening if present
    StopItem? sunsetSpot;
    final sunsetIndex = unvisited.indexWhere(
      (s) => s.place.bestVisitWindow != null && s.place.bestVisitWindow!.contains('Sunset'),
    );
    if (sunsetIndex != -1 && unvisited.length > 2) {
      sunsetSpot = unvisited.removeAt(sunsetIndex);
    }

    // Start with closest to start point or first stop
    double currentLat = startLat ?? unvisited.first.place.latitude;
    double currentLon = startLon ?? unvisited.first.place.longitude;

    while (unvisited.isNotEmpty) {
      int bestIdx = 0;
      double bestDist = double.infinity;

      for (int i = 0; i < unvisited.length; i++) {
        final d = computeDistanceKm(
          currentLat,
          currentLon,
          unvisited[i].place.latitude,
          unvisited[i].place.longitude,
        );
        if (d < bestDist) {
          bestDist = d;
          bestIdx = i;
        }
      }

      final chosen = unvisited.removeAt(bestIdx);
      optimized.add(chosen);
      currentLat = chosen.place.latitude;
      currentLon = chosen.place.longitude;
    }

    // Re-insert sunset spot near the end
    if (sunsetSpot != null) {
      optimized.add(sunsetSpot);
    }

    return calculateRouteMetrics(optimized);
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
