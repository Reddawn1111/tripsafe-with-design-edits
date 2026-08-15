import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/expense_model.dart';
import '../../models/trip_plan.dart';
import '../../services/group_trip_service.dart';
import '../../services/trip_planning_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';

/// ExpensesScreen — group expense tracking, dark "accent panel" theme.
/// Layout order unchanged: total panel, settlement action, expense list.
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
          title: const Text('Add group expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (₹)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ExpenseCategory>(
                initialValue: selectedCat,
                decoration: const InputDecoration(labelText: 'Category'),
                dropdownColor: AppTheme.cardDark,
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
            TextButton(
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
    final members = activeTrip?.members ??
        [
          GroupMember(id: 'mem_1', name: 'You (Organizer)'),
          GroupMember(id: 'mem_2', name: 'Aarav'),
          GroupMember(id: 'mem_3', name: 'Ananya'),
        ];

    return Scaffold(
      appBar: TripSafeAppBar(
        title: 'Expenses',
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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AccentPanel(
                  color: AppTheme.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL GROUP SPENT',
                        style: AppTypography.sectionLabel.copyWith(
                          fontSize: 10.5,
                          letterSpacing: 1.8,
                          color: AppTheme.onPrimary.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${total.toStringAsFixed(0)}',
                        style: AppTypography.displayLarge.copyWith(
                          color: AppTheme.onPrimary,
                          fontSize: 42,
                          letterSpacing: -1.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '~₹${perPerson.toStringAsFixed(0)} per person · ${members.length} members',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppTheme.onPrimary.withValues(alpha: 0.78),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PillButton(
                        label: 'Add bill',
                        icon: Icons.add,
                        color: AppTheme.onPrimary,
                        onPressed: _showAddExpenseDialog,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                SecondaryButton(
                  label: 'Calculate split & settlement',
                  icon: Icons.calculate_outlined,
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.settlement),
                ),

                const SizedBox(height: 22),
                SectionLabel('Recorded expenses · ${expenses.length}'),
                const SizedBox(height: 11),

                if (expenses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Center(
                      child: Text(
                        'No group expenses recorded yet.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppTheme.muted(context),
                        ),
                      ),
                    ),
                  )
                else
                  ...expenses.map(
                    (exp) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppTheme.tint(AppTheme.primary, 0.12),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Text(
                                exp.category.iconEmoji,
                                style: const TextStyle(fontSize: 17),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exp.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.titleSmall,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Paid by ${exp.paidByMemberName} · split ${exp.splitAmongMemberIds.length} ways',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 11,
                                      color: AppTheme.muted(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '₹${exp.amount.round()}',
                              style: AppTypography.titleMedium,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 17),
                              color: AppTheme.muted(context),
                              visualDensity: VisualDensity.compact,
                              onPressed: () =>
                                  _groupService.removeExpense(exp.id),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
