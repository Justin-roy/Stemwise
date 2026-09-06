import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/providers.dart';

class University {
  final String id, name, type;
  final String country;
  final String? state, city, dataSource, lastUpdated, website;
  University({
    required this.id,
    required this.name,
    required this.type,
    required this.country,
    this.state,
    this.city,
    this.dataSource,
    this.lastUpdated,
    this.website,
  });
  factory University.fromJson(Map<String, dynamic> j) {
    final loc = (j['location'] ?? {}) as Map<String, dynamic>;
    return University(
      id: (j['_id'] ?? j['id']).toString(),
      name: j['name'] as String,
      type: (j['type'] ?? 'public') as String,
      country: (loc['country'] ?? '') as String,
      state: loc['state'] as String?,
      city: loc['city'] as String?,
      dataSource: j['dataSource'] as String?,
      lastUpdated: j['lastUpdated'] as String?,
      website: j['website'] as String?,
    );
  }
  String get locationLabel =>
      [city, state, country].where((e) => e != null && e.isNotEmpty).join(', ');
}

class Program {
  final String id, name, field, degreeLevel;
  final int durationYears;
  final double tuitionAnnual, feesAnnual, livingCostAnnual;
  Program({
    required this.id,
    required this.name,
    required this.field,
    required this.degreeLevel,
    required this.durationYears,
    required this.tuitionAnnual,
    required this.feesAnnual,
    required this.livingCostAnnual,
  });
  factory Program.fromJson(Map<String, dynamic> j) => Program(
        id: (j['_id'] ?? j['id']).toString(),
        name: j['name'] as String,
        field: j['field'] as String,
        degreeLevel: j['degreeLevel'] as String,
        durationYears: (j['durationYears'] ?? 4).toInt(),
        tuitionAnnual: (j['tuitionAnnual'] ?? 0).toDouble(),
        feesAnnual: (j['feesAnnual'] ?? 0).toDouble(),
        livingCostAnnual: (j['livingCostAnnual'] ?? 0).toDouble(),
      );
}

class UniversitiesRepository {
  UniversitiesRepository(this._api);
  final ApiClient _api;

  Future<List<University>> search({
    String? query,
    String? field,
    String? degreeLevel,
    int limit = 20,
  }) async {
    final res = await _api.get('/universities', query: {
      if (query != null && query.isNotEmpty) 'search': query,
      if (field != null) 'field': field,
      if (degreeLevel != null) 'degreeLevel': degreeLevel,
      'limit': limit,
    });
    final list = (res is Map ? res['data'] : res) as List;
    return list.map((e) => University.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<University> byId(String id) async {
    final data = await _api.get('/universities/$id');
    return University.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Program>> programs(String universityId) async {
    final data = await _api.get('/universities/$universityId/programs');
    return (data as List).map((e) => Program.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final universitiesRepositoryProvider =
    Provider<UniversitiesRepository>((ref) => UniversitiesRepository(ref.watch(apiClientProvider)));
