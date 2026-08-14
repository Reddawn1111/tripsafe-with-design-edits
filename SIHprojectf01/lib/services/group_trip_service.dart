import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import '../models/trip_plan.dart';

/// Service managing group travel collaboration, shared expenses, and settlements (Step 9)
class GroupTripService extends ChangeNotifier {
  static final GroupTripService instance = GroupTripService._internal();
  factory GroupTripService() => instance;
  GroupTripService._internal() {
    _initDemoExpenses();
  }

  final List<TripExpense> _expenses = [];
  List<TripExpense> get expenses => List.unmodifiable(_expenses);

  double get totalSpent =>
      _expenses.fold(0.0, (sum, exp) => sum + exp.amount);

  void addExpense(TripExpense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void removeExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// Calculates simplified debts / settlement balances ("Who owes whom")
  List<MemberSettlement> calculateSettlements(List<GroupMember> members) {
    if (members.isEmpty || _expenses.isEmpty) return [];

    final Map<String, double> netBalances = {};
    for (final m in members) {
      netBalances[m.name] = 0.0;
    }

    for (final exp in _expenses) {
      final payerName = exp.paidByMemberName;
      final splitCount = exp.splitAmongMemberIds.isNotEmpty ? exp.splitAmongMemberIds.length : members.length;
      final perPersonShare = exp.amount / splitCount;

      netBalances[payerName] = (netBalances[payerName] ?? 0.0) + exp.amount;

      for (final m in members) {
        if (exp.splitAmongMemberIds.isEmpty || exp.splitAmongMemberIds.contains(m.id)) {
          netBalances[m.name] = (netBalances[m.name] ?? 0.0) - perPersonShare;
        }
      }
    }

    final List<MapEntry<String, double>> creditors = [];
    final List<MapEntry<String, double>> debtors = [];

    netBalances.forEach((name, balance) {
      if (balance > 0.5) {
        creditors.add(MapEntry(name, balance));
      } else if (balance < -0.5) {
        debtors.add(MapEntry(name, -balance));
      }
    });

    final List<MemberSettlement> settlements = [];
    int cIdx = 0;
    int dIdx = 0;

    while (cIdx < creditors.length && dIdx < debtors.length) {
      final creditor = creditors[cIdx];
      final debtor = debtors[dIdx];

      final amount = creditor.value < debtor.value ? creditor.value : debtor.value;
      if (amount > 0.5) {
        settlements.add(
          MemberSettlement(
            fromMemberName: debtor.key,
            toMemberName: creditor.key,
            amount: amount,
          ),
        );
      }

      creditors[cIdx] = MapEntry(creditor.key, creditor.value - amount);
      debtors[dIdx] = MapEntry(debtor.key, debtor.value - amount);

      if (creditors[cIdx].value <= 0.5) cIdx++;
      if (debtors[dIdx].value <= 0.5) dIdx++;
    }

    return settlements;
  }

  void _initDemoExpenses() {
    final now = DateTime.now();
    _expenses.addAll([
      TripExpense(
        id: 'exp_1',
        title: 'Group Welcome Lunch at Spice Route',
        amount: 1450.0,
        category: ExpenseCategory.food,
        paidByMemberId: 'mem_1',
        paidByMemberName: 'You (Organizer)',
        date: now.subtract(const Duration(hours: 4)),
        splitAmongMemberIds: ['mem_1', 'mem_2', 'mem_3'],
      ),
      TripExpense(
        id: 'exp_2',
        title: 'Cab transit from station to hotel',
        amount: 480.0,
        category: ExpenseCategory.transport,
        paidByMemberId: 'mem_2',
        paidByMemberName: 'Aarav',
        date: now.subtract(const Duration(hours: 6)),
        splitAmongMemberIds: ['mem_1', 'mem_2', 'mem_3'],
      ),
      TripExpense(
        id: 'exp_3',
        title: 'Botanical Garden Entry Passes',
        amount: 270.0,
        category: ExpenseCategory.activity,
        paidByMemberId: 'mem_3',
        paidByMemberName: 'Ananya',
        date: now.subtract(const Duration(hours: 2)),
        splitAmongMemberIds: ['mem_1', 'mem_2', 'mem_3'],
      ),
    ]);
  }
}
