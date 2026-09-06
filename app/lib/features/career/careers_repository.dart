import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/providers.dart';

class Career {
  final String slug, title, description, field;
  final double startingSalary;
  final double? salaryRangeMin, salaryRangeMax;
  final String? typicalDegreeLevel, educationRequirements, source, lastUpdated;
  final int? typicalProgramYears;

  Career({
    required this.slug,
    required this.title,
    required this.description,
    required this.field,
    required this.startingSalary,
    this.salaryRangeMin,
    this.salaryRangeMax,
    this.typicalDegreeLevel,
    this.educationRequirements,
    this.source,
    this.lastUpdated,
    this.typicalProgramYears,
  });

  factory Career.fromJson(Map<String, dynamic> j) => Career(
        slug: j['slug'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
        field: j['field'] as String,
        startingSalary: (j['startingSalary'] ?? 0).toDouble(),
        salaryRangeMin: (j['salaryRangeMin'] as num?)?.toDouble(),
        salaryRangeMax: (j['salaryRangeMax'] as num?)?.toDouble(),
        typicalDegreeLevel: j['typicalDegreeLevel'] as String?,
        educationRequirements: j['educationRequirements'] as String?,
        source: j['source'] as String?,
        lastUpdated: j['lastUpdated'] as String?,
        typicalProgramYears: (j['typicalProgramYears'] as num?)?.toInt(),
      );
}

class CareersRepository {
  CareersRepository(this._api);
  final ApiClient _api;

  Future<List<Career>> list({String? field}) async {
    final data = await _api.get('/careers', query: {if (field != null) 'field': field});
    return (data as List).map((e) => Career.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Career> bySlug(String slug) async {
    final data = await _api.get('/careers/$slug');
    return Career.fromJson(data as Map<String, dynamic>);
  }
}

final careersRepositoryProvider =
    Provider<CareersRepository>((ref) => CareersRepository(ref.watch(apiClientProvider)));

final careersProvider = FutureProvider.family<List<Career>, String?>((ref, field) {
  return ref.watch(careersRepositoryProvider).list(field: field);
});
