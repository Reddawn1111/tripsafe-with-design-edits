import 'place.dart';

/// Group member in a collaborative TripSafe trip
class GroupMember {
  final String id;
  final String name;
  final String role; // 'Organizer', 'Traveller', 'Viewer'
  final String? avatarInitials;
  final double shareRatio; // For split expenses (default 1.0)

  GroupMember({
    required this.id,
    required this.name,
    this.role = 'Traveller',
    this.avatarInitials,
    this.shareRatio = 1.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'avatarInitials': avatarInitials,
    'shareRatio': shareRatio,
  };

  factory GroupMember.fromJson(Map<String, dynamic> json) => GroupMember(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? 'Traveller',
    role: json['role'] as String? ?? 'Traveller',
    avatarInitials: json['avatarInitials'] as String?,
    shareRatio: (json['shareRatio'] as num?)?.toDouble() ?? 1.0,
  );
}

/// A stop in an itinerary with route & timing intelligence
class StopItem {
  final String id;
  final Place place;
  final String startTime; // e.g. "10:00 AM"
  final String endTime; // e.g. "11:30 AM"
  final int estimatedDurationMinutes;
  final int travelTimeFromPreviousMinutes;
  final double distanceFromPreviousKm;
  final double estimatedCost;
  bool isVisited;
  final String? userNotes;
  final String? optimizationHint;

  StopItem({
    required this.id,
    required this.place,
    required this.startTime,
    required this.endTime,
    required this.estimatedDurationMinutes,
    this.travelTimeFromPreviousMinutes = 0,
    this.distanceFromPreviousKm = 0.0,
    this.estimatedCost = 0.0,
    this.isVisited = false,
    this.userNotes,
    this.optimizationHint,
  });

  StopItem copyWith({
    String? startTime,
    String? endTime,
    int? estimatedDurationMinutes,
    int? travelTimeFromPreviousMinutes,
    double? distanceFromPreviousKm,
    double? estimatedCost,
    bool? isVisited,
    String? userNotes,
    String? optimizationHint,
  }) {
    return StopItem(
      id: id,
      place: place,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      travelTimeFromPreviousMinutes:
          travelTimeFromPreviousMinutes ?? this.travelTimeFromPreviousMinutes,
      distanceFromPreviousKm:
          distanceFromPreviousKm ?? this.distanceFromPreviousKm,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      isVisited: isVisited ?? this.isVisited,
      userNotes: userNotes ?? this.userNotes,
      optimizationHint: optimizationHint ?? this.optimizationHint,
    );
  }
}

/// A day within a trip plan
class DayPlan {
  final int dayNumber;
  final DateTime date;
  final String title;
  final List<StopItem> stops;

  DayPlan({
    required this.dayNumber,
    required this.date,
    required this.title,
    required this.stops,
  });

  double get totalPlannedCost =>
      stops.fold(0.0, (sum, stop) => sum + stop.estimatedCost);

  int get totalEstimatedDurationMinutes =>
      stops.fold(0, (sum, stop) => sum + stop.estimatedDurationMinutes + stop.travelTimeFromPreviousMinutes);

  double get totalDistanceKm =>
      stops.fold(0.0, (sum, stop) => sum + stop.distanceFromPreviousKm);

  DayPlan copyWith({
    String? title,
    List<StopItem>? stops,
  }) {
    return DayPlan(
      dayNumber: dayNumber,
      date: date,
      title: title ?? this.title,
      stops: stops ?? this.stops,
    );
  }
}

/// User input preferences for Trip Planner
class TripPreferences {
  final String destinationName;
  final double? destinationLat;
  final double? destinationLng;
  final int durationDays;
  final double budgetPerPerson;
  final int groupSize;
  final List<String> interests;
  final int availableHoursPerDay;
  final String pace; // 'Relaxed', 'Moderate', 'Intensive'

  TripPreferences({
    required this.destinationName,
    this.destinationLat,
    this.destinationLng,
    this.durationDays = 1,
    this.budgetPerPerson = 1500.0,
    this.groupSize = 1,
    this.interests = const ['Explore', 'Eat', 'Photos'],
    this.availableHoursPerDay = 8,
    this.pace = 'Moderate',
  });

  double get totalTripBudget => budgetPerPerson * groupSize;
}

/// Comprehensive Trip Plan model
class TripPlan {
  final String id;
  final String title;
  final String destinationName;
  final double destinationLat;
  final double destinationLng;
  final DateTime startDate;
  final DateTime endDate;
  final double totalBudget;
  final List<GroupMember> members;
  final List<DayPlan> days;
  final String status; // 'planning', 'active', 'completed'
  final String inviteCode;
  final String safetyAdvisory;

  TripPlan({
    required this.id,
    required this.title,
    required this.destinationName,
    required this.destinationLat,
    required this.destinationLng,
    DateTime? startDate,
    DateTime? endDate,
    required this.totalBudget,
    this.members = const [],
    required this.days,
    this.status = 'planning',
    this.inviteCode = 'TRIP-7492',
    this.safetyAdvisory = 'All regions clear. Good travel conditions.',
  })  : startDate = startDate ?? DateTime.now(),
        endDate = endDate ?? DateTime.now().add(const Duration(days: 2));

  double get totalSpentOrPlanned {
    double total = 0.0;
    for (final day in days) {
      total += day.totalPlannedCost;
    }
    return total;
  }

  double get remainingBudget => totalBudget - totalSpentOrPlanned;

  int get totalStopsCount =>
      days.fold(0, (sum, day) => sum + day.stops.length);

  int get completedStopsCount =>
      days.fold(0, (sum, day) => sum + day.stops.where((s) => s.isVisited).length);

  double get progressPercentage =>
      totalStopsCount == 0 ? 0.0 : completedStopsCount / totalStopsCount;

  TripPlan copyWith({
    String? title,
    String? status,
    List<GroupMember>? members,
    List<DayPlan>? days,
    double? totalBudget,
    String? safetyAdvisory,
  }) {
    return TripPlan(
      id: id,
      title: title ?? this.title,
      destinationName: destinationName,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      startDate: startDate,
      endDate: endDate,
      totalBudget: totalBudget ?? this.totalBudget,
      members: members ?? this.members,
      days: days ?? this.days,
      status: status ?? this.status,
      inviteCode: inviteCode,
      safetyAdvisory: safetyAdvisory ?? this.safetyAdvisory,
    );
  }
}
