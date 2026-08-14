/// Categories for group and individual travel expenses
enum ExpenseCategory {
  food('Food & Dining', '🍴'),
  transport('Transport & Fuel', '🚕'),
  stay('Stay & Hotels', '🏨'),
  activity('Activities & Tickets', '🎟️'),
  shopping('Shopping & Souvenirs', '🛍️'),
  misc('Miscellaneous', '💳');

  final String label;
  final String iconEmoji;
  const ExpenseCategory(this.label, this.iconEmoji);
}

/// A recorded expense within a trip
class TripExpense {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final String paidByMemberId;
  final String paidByMemberName;
  final DateTime date;
  final List<String> splitAmongMemberIds;

  TripExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.paidByMemberId,
    required this.paidByMemberName,
    required this.date,
    required this.splitAmongMemberIds,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category.name,
    'paidByMemberId': paidByMemberId,
    'paidByMemberName': paidByMemberName,
    'date': date.toIso8601String(),
    'splitAmongMemberIds': splitAmongMemberIds,
  };
}

/// Balance calculation for split settlement
class MemberSettlement {
  final String fromMemberName;
  final String toMemberName;
  final double amount;

  MemberSettlement({
    required this.fromMemberName,
    required this.toMemberName,
    required this.amount,
  });
}
