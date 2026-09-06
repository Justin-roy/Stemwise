import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import '../calculator/domain/calculation_inputs.dart';
import '../calculator/domain/calculation_result.dart';

class SavedPlan {
  final String id, name;
  final String? field, degreeLevel;
  final CalculationInputs inputs;
  final FullResult? results;

  SavedPlan({
    required this.id,
    required this.name,
    this.field,
    this.degreeLevel,
    required this.inputs,
    this.results,
  });

  factory SavedPlan.fromJson(Map<String, dynamic> j) => SavedPlan(
        id: (j['_id'] ?? j['id']).toString(),
        name: j['name'] as String,
        field: j['field'] as String?,
        degreeLevel: j['degreeLevel'] as String?,
        inputs: CalculationInputs.fromJson(j['inputs'] as Map<String, dynamic>),
        results: j['results'] != null
            ? FullResult.fromJson(j['results'] as Map<String, dynamic>)
            : null,
      );
}

class SavedPlansRepository {
  SavedPlansRepository(this._api);
  final ApiClient _api;

  Future<SavedPlan> create({
    required String name,
    String? field,
    String? degreeLevel,
    String? universityId,
    required CalculationInputs inputs,
  }) async {
    final data = await _api.post('/saved-plans', body: {
      'name': name,
      if (field != null) 'field': field,
      if (degreeLevel != null) 'degreeLevel': degreeLevel,
      if (universityId != null) 'universityId': universityId,
      'inputs': inputs.toJson(),
    });
    return SavedPlan.fromJson(data as Map<String, dynamic>);
  }

  Future<List<SavedPlan>> list() async {
    final data = await _api.get('/saved-plans');
    return (data as List).map((e) => SavedPlan.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> delete(String id) => _api.delete('/saved-plans/$id');
}

final savedPlansRepositoryProvider =
    Provider<SavedPlansRepository>((ref) => SavedPlansRepository(ref.watch(apiClientProvider)));

final savedPlansProvider = FutureProvider.autoDispose<List<SavedPlan>>(
    (ref) => ref.watch(savedPlansRepositoryProvider).list());
