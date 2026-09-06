import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../domain/calculation_inputs.dart';
import '../domain/calculation_result.dart';

/// Talks to the authoritative backend calculation endpoints (spec §62).
class CalculationsRepository {
  CalculationsRepository(this._api);
  final ApiClient _api;

  Future<FullResult> full(CalculationInputs inputs) async {
    final data = await _api.post('/calculations/full', body: inputs.toJson());
    return FullResult.fromJson(data as Map<String, dynamic>);
  }

  Future<WhatIfResult> whatIf(
      CalculationInputs baseline, CalculationInputs scenario) async {
    final data = await _api.post('/calculations/what-if', body: {
      'baseline': baseline.toJson(),
      'scenario': scenario.toJson(),
    });
    return WhatIfResult.fromJson(data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> assumptions() async {
    final data = await _api.get('/calculations/assumptions');
    return data as Map<String, dynamic>;
  }
}

final calculationsRepositoryProvider = Provider<CalculationsRepository>(
  (ref) => CalculationsRepository(ref.watch(apiClientProvider)),
);
