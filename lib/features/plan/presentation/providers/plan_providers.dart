import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/plan_model.dart';
import '../../data/repositories/plan_repository.dart';

final planRepositoryProvider = Provider<PlanRepository>(
  (ref) => PlanRepository(),
);

/// Today, overridable in tests.
final todayProvider = Provider<DateTime>((ref) => DateTime.now());

final currentYearProvider = Provider<int>(
  (ref) => ref.watch(todayProvider).year,
);

/// Ensures the current year's plan (and its two meals) exists. Re-runs when
/// the user or the year changes.
final ensuredPlanProvider = FutureProvider<PlanModel>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw StateError('Not signed in');
  final year = ref.watch(currentYearProvider);
  return ref.watch(planRepositoryProvider).ensurePlan(year);
});

/// Every plan the user has, newest first. Live.
final plansProvider = StreamProvider<List<PlanModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(planRepositoryProvider).watchPlans();
});

/// The current year's plan: ensured first, then the live row once the
/// stream carries it, so a budget edit shows everywhere at once.
final currentPlanProvider = Provider<AsyncValue<PlanModel>>((ref) {
  final ensured = ref.watch(ensuredPlanProvider);
  final plans = ref.watch(plansProvider);
  return ensured.whenData((p) {
    final live = plans.asData?.value.where((x) => x.id == p.id);
    return (live != null && live.isNotEmpty) ? live.first : p;
  });
});

/// The year being viewed; null means the current year.
final selectedYearProvider = NotifierProvider<SelectedYear, int?>(
  SelectedYear.new,
);

class SelectedYear extends Notifier<int?> {
  @override
  int? build() => null;
  void select(int? year) => state = year;
}

/// The plan being viewed: the current one, or a previous year read-only.
final selectedPlanProvider = Provider<AsyncValue<PlanModel>>((ref) {
  final year = ref.watch(selectedYearProvider);
  final current = ref.watch(currentYearProvider);
  if (year == null || year == current) return ref.watch(currentPlanProvider);
  return ref.watch(plansProvider).whenData((list) {
    final found = list.where((p) => p.year == year);
    if (found.isEmpty) throw StateError('No plan for $year');
    return found.first;
  });
});

/// A previous year is read-only: no add, edit, delete or status change.
final readOnlyProvider = Provider<bool>((ref) {
  final year = ref.watch(selectedYearProvider);
  return year != null && year < ref.watch(currentYearProvider);
});

/// Years before the current one that have a plan, newest first.
final previousYearsProvider = Provider<List<int>>((ref) {
  final current = ref.watch(currentYearProvider);
  final plans = ref.watch(plansProvider).asData?.value ?? const [];
  return [
    for (final p in plans)
      if (p.year < current) p.year,
  ];
});

final planControllerProvider = Provider<PlanController>(
  (ref) => PlanController(ref),
);

class PlanController {
  PlanController(this._ref);
  final Ref _ref;

  Future<void> updateGiftBudget(String planId, double amount) async {
    await _ref.read(planRepositoryProvider).updateGiftBudget(planId, amount);
    _ref.invalidate(ensuredPlanProvider);
  }
}
