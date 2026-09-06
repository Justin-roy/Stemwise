import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/stemwise_card.dart';
import '../calculator/application/calculations_repository.dart';
import '../calculator/domain/calculation_inputs.dart';
import '../calculator/domain/calculation_result.dart';
import '../career/careers_repository.dart';
import '../university/universities_repository.dart';

class CompareEntry {
  final University university;
  final Program program;
  final FullResult result;
  CompareEntry(this.university, this.program, this.result);
}

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});
  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<University> _results = [];
  bool _searching = false;
  String? _searchError;
  final List<CompareEntry> _selected = [];

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(q));
  }

  Future<void> _search(String q) async {
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final r = await ref.read(universitiesRepositoryProvider).search(query: q);
      if (mounted) setState(() => _results = r);
    } catch (e) {
      if (mounted) setState(() => _searchError = e.toString());
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _add(University u) async {
    if (_selected.any((e) => e.university.id == u.id)) return;
    if (_selected.length >= 4) {
      _showLimit();
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    try {
      final programs = await ref.read(universitiesRepositoryProvider).programs(u.id);
      if (programs.isEmpty) {
        messenger.showSnackBar(const SnackBar(content: Text('No program data for this university.')));
        return;
      }
      final program = programs.first;
      final careers = await ref.read(careersRepositoryProvider).list(field: program.field);
      final salary = careers.isNotEmpty ? careers.first.startingSalary : 70000.0;

      final inputs = CalculationInputs(
        costs: CostInputs(
          tuitionAnnual: program.tuitionAnnual + program.feesAnnual,
          housingAnnual: program.livingCostAnnual * 0.6,
          foodAnnual: program.livingCostAnnual * 0.25,
          transportationAnnual: program.livingCostAnnual * 0.15,
          programYears: program.durationYears,
        ),
        funding: const FundingInputs(),
        loan: const LoanInputs(),
        career: CareerInputs(startingSalary: salary),
      );
      final result = await ref.read(calculationsRepositoryProvider).full(inputs);
      setState(() => _selected.add(CompareEntry(u, program, result)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _showLimit() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Compare up to 4'),
        content: const Text('You can compare up to 4 universities. Remove one to add another.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Best value = lowest projected borrowing among compared (transparent criterion, §36).
    String? bestId;
    if (_selected.length > 1) {
      final best = _selected.reduce(
          (a, b) => a.result.loan.principal <= b.result.loan.principal ? a : b);
      bestId = best.university.id;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Compare universities')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search universities...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                          : null,
                    ),
                  ),
                ),
                if (_selected.isNotEmpty)
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: _selected
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Chip(
                                  label: Text(e.university.name, overflow: TextOverflow.ellipsis),
                                  onDeleted: () =>
                                      setState(() => _selected.removeWhere((x) => x.university.id == e.university.id)),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                Expanded(
                  child: _selected.length >= 2
                      ? _comparisonTable(bestId)
                      : _searchList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchList() {
    if (_searchError != null) {
      return ErrorStateView(message: _searchError!, onRetry: () => _search(_searchController.text));
    }
    if (_results.isEmpty && !_searching) {
      return const EmptyState(
          icon: Icons.school_outlined, title: 'No universities found.', message: 'Try a different search.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final u = _results[i];
        final added = _selected.any((e) => e.university.id == u.id);
        return StemwiseCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('${u.locationLabel} • ${u.type}',
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                  ],
                ),
              ),
              TextButton(
                onPressed: added ? null : () => _add(u),
                child: Text(added ? 'Added' : 'Add to Compare'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _comparisonTable(String? bestId) {
    final rows = <_Row>[
      _Row('Total cost', (e) => Fmt.money(e.result.cost.totalEducationCost)),
      _Row('Projected debt', (e) => Fmt.money(e.result.loan.principal)),
      _Row('Starting salary', (e) => Fmt.money(e.result.career.startingSalary)),
      _Row('Monthly payment', (e) => Fmt.moneyCents(e.result.loan.monthlyPayment)),
      _Row('Debt burden', (e) => Fmt.percent(e.result.debtBurden.loanPaymentBurden)),
      _Row('Program duration', (e) => '${e.program.durationYears} yrs'),
      _Row('Planning score', (e) => '${e.result.score.score}/100'),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 22,
            columns: [
              const DataColumn(label: Text('Metric', style: TextStyle(fontWeight: FontWeight.w700))),
              ..._selected.map((e) => DataColumn(
                    label: SizedBox(
                      width: 110,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(e.university.name,
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                          if (e.university.id == bestId)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: AppColors.veryLightGreen,
                                  borderRadius: BorderRadius.circular(999)),
                              child: const Text('Best value',
                                  style: TextStyle(fontSize: 9.5, color: AppColors.darkGreen, fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                    ),
                  )),
            ],
            rows: rows
                .map((r) => DataRow(cells: [
                      DataCell(Text(r.label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5))),
                      ..._selected.map((e) => DataCell(Text(r.value(e),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)))),
                    ]))
                .toList(),
          ),
        ),
        if (bestId != null) ...[
          const SizedBox(height: 12),
          StemwiseCard(
            color: AppColors.veryLightGreen,
            borderColor: AppColors.lightGreen,
            child: const Text(
              'Best financial value is selected by lowest projected borrowing among the compared programs, under identical funding assumptions. Consider expected salary and fit too.',
              style: TextStyle(fontSize: 12.5, color: AppColors.darkGreen, height: 1.4),
            ),
          ),
        ],
        const SizedBox(height: 12),
        const DisclaimerCard(compact: true),
      ],
    );
  }
}

class _Row {
  final String label;
  final String Function(CompareEntry) value;
  _Row(this.label, this.value);
}
