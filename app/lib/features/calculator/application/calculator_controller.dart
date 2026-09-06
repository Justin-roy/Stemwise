import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers.dart';
import '../domain/calculation_inputs.dart';

/// Field metadata (spec §14).
class StemField {
  final String slug;
  final String label;
  const StemField(this.slug, this.label);
}

const kStemFields = [
  StemField('computer-science', 'Computer Science'),
  StemField('engineering', 'Engineering'),
  StemField('data-science', 'Data Science'),
  StemField('biotechnology', 'Biotechnology'),
  StemField('mathematics', 'Mathematics'),
  StemField('physics', 'Physics'),
  StemField('other', 'Other'),
];

@immutable
class CalculatorState {
  final CalculationInputs inputs;
  final String? field;
  final String? degreeLevel; // bachelors | masters | phd
  final String? universityName;
  final String? universityId;
  final bool started;

  const CalculatorState({
    required this.inputs,
    this.field,
    this.degreeLevel,
    this.universityName,
    this.universityId,
    this.started = false,
  });

  factory CalculatorState.initial() =>
      CalculatorState(inputs: CalculationInputs.initial());

  /// Rough completion for the "continue your plan" prompt (spec §103).
  int get percentComplete {
    var done = 0;
    const total = 5;
    if (field != null && degreeLevel != null) done++;
    if (inputs.costs.tuitionAnnual > 0) done++;
    if (LocalHas.anyFunding(inputs)) done++;
    if (inputs.loan.repaymentYears > 0) done++;
    if (inputs.career.startingSalary > 0) done++;
    return ((done / total) * 100).round();
  }

  CalculatorState copyWith({
    CalculationInputs? inputs,
    String? field,
    String? degreeLevel,
    String? universityName,
    String? universityId,
    bool? started,
  }) =>
      CalculatorState(
        inputs: inputs ?? this.inputs,
        field: field ?? this.field,
        degreeLevel: degreeLevel ?? this.degreeLevel,
        universityName: universityName ?? this.universityName,
        universityId: universityId ?? this.universityId,
        started: started ?? this.started,
      );

  Map<String, dynamic> toJson() => {
        'inputs': inputs.toJson(),
        'field': field,
        'degreeLevel': degreeLevel,
        'universityName': universityName,
        'universityId': universityId,
        'started': started,
      };

  factory CalculatorState.fromJson(Map<String, dynamic> j) => CalculatorState(
        inputs: CalculationInputs.fromJson(j['inputs'] ?? {}),
        field: j['field'],
        degreeLevel: j['degreeLevel'],
        universityName: j['universityName'],
        universityId: j['universityId'],
        started: j['started'] ?? false,
      );
}

class LocalHas {
  static bool anyFunding(CalculationInputs i) {
    final f = i.funding;
    return f.scholarships +
            f.grants +
            f.savings +
            f.familyContribution +
            f.assistantship +
            f.employerContribution +
            f.otherFunding >
        0;
  }
}

/// Holds the calculator inputs and persists them so anonymous users never lose
/// progress — including across signup (spec §47, §76, RULE 12).
class CalculatorController extends StateNotifier<CalculatorState> {
  CalculatorController(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;
  static const _key = 'calculator_state_v1';

  static CalculatorState _load(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null) return CalculatorState.initial();
    try {
      return CalculatorState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return CalculatorState.initial();
    }
  }

  void _persist() => _prefs.setString(_key, jsonEncode(state.toJson()));

  void _set(CalculatorState s) {
    state = s;
    _persist();
  }

  void setField(String field) => _set(state.copyWith(field: field, started: true));
  void setDegreeLevel(String level) => _set(state.copyWith(degreeLevel: level));

  void setUniversity({String? name, String? id}) =>
      _set(state.copyWith(universityName: name, universityId: id));

  void updateCosts(CostInputs costs) =>
      _set(state.copyWith(inputs: state.inputs.copyWith(costs: costs)));

  void updateFunding(FundingInputs funding) =>
      _set(state.copyWith(inputs: state.inputs.copyWith(funding: funding)));

  void updateLoan(LoanInputs loan) =>
      _set(state.copyWith(inputs: state.inputs.copyWith(loan: loan)));

  void updateCareer(CareerInputs career) =>
      _set(state.copyWith(inputs: state.inputs.copyWith(career: career)));

  /// Prefill costs from a university program (spec §37, §101).
  void applyProgram({
    required String field,
    required String degreeLevel,
    required String universityName,
    required String universityId,
    required double tuitionAnnual,
    required double feesAnnual,
    required double livingCostAnnual,
    required int durationYears,
  }) {
    final costs = state.inputs.costs.copyWith(
      tuitionAnnual: tuitionAnnual + feesAnnual,
      housingAnnual: livingCostAnnual * 0.6,
      foodAnnual: livingCostAnnual * 0.25,
      transportationAnnual: livingCostAnnual * 0.15,
      programYears: durationYears,
    );
    _set(state.copyWith(
      field: field,
      degreeLevel: degreeLevel,
      universityName: universityName,
      universityId: universityId,
      started: true,
      inputs: state.inputs.copyWith(costs: costs),
    ));
  }

  void reset() {
    _prefs.remove(_key);
    state = CalculatorState.initial();
  }
}

final calculatorControllerProvider =
    StateNotifierProvider<CalculatorController, CalculatorState>((ref) {
  return CalculatorController(ref.watch(sharedPrefsProvider));
});
