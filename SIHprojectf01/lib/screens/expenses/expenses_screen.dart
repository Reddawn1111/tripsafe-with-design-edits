import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/expense_model.dart';
import '../../models/trip_plan.dart';
import '../../services/group_trip_service.dart';
import '../../services/trip_planning_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// ExpensesScreen — Group expense tracking and split overview (Step 9)
class ExpensesScreen extends StatefulWidget {
  final String tripId;
  const ExpensesScreen({super.key, this.tripId = ''});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _groupService = GroupTripService.instance;
  final _planningService = TripPlanningService.instance;

  void _showAddExpenseDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    ExpenseCategory selectedCat = ExpenseCategory.food;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Group Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Expense Description'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (₹)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ExpenseCategory>(
                initialValue: selectedCat,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ExpenseCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text('${cat.iconEmoji} ${cat.label}'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedCat = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amountCtrl.text) ?? 0.0;
                if (titleCtrl.text.trim().isNotEmpty && amt > 0) {
                  _groupService.addExpense(
                    TripExpense(
                      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
                      title: titleCtrl.text.trim(),
                      amount: amt,
                      category: selectedCat,
                      paidByMemberId: 'mem_1',
                      paidByMemberName: 'You (Organizer)',
                      date: DateTime.now(),
                      splitAmongMemberIds: ['mem_1', 'mem_2', 'mem_3'],
                    ),
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTrip = _planningService.activeTrip;
    final members = activeTrip?.members ?? [
      GroupMember(id: 'mem_1', name: 'You (Organizer)'),
      GroupMember(id: 'mem_2', name: 'Aarav'),
      GroupMember(id: 'mem_3', name: 'Ananya'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Travel Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.handshake_outlined),
            tooltip: 'Settlement Summary',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settlement),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _groupService,
        builder: (context, _) {
          final expenses = _groupService.expenses;
          final total = _groupService.totalSpent;
          final perPerson = members.isNotEmpty ? total / members.length : 0.0;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Spent Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.85)],
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL GROUP SPENT',
                            style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${total.toStringAsFixed(0)}',
                            style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '~₹${perPerson.toStringAsFixed(0)} per person (${members.length} members)',
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primary,
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Bill'),
                        onPressed: _showAddExpenseDialog,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Quick Settlement Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  icon: const Icon(Icons.calculate_outlined),
                  label: const Text('Calculate Split & Settlement'),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.settlement),
                ),

                const SizedBox(height: AppSpacing.md),

                // Expense List
                Text('Recorded Expenses (${expenses.length})', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                if (expenses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: Text('No group expenses recorded yet.')),
                  )
                else
                  ...expenses.map(
                    (exp) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AppCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                              child: Text(exp.category.iconEmoji),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(exp.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                    'Paid by ${exp.paidByMemberName} · Split equally (${exp.splitAmongMemberIds.length})',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${exp.amount.round()}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                              onPressed: () => _groupService.removeExpense(exp.id),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }
}
