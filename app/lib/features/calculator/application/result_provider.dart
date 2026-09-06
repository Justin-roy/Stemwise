import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/calculation_result.dart';
import 'calculations_repository.dart';
import 'calculator_controller.dart';

/// Fetches the AUTHORITATIVE full result from the backend for the current inputs.
final fullResultProvider = FutureProvider.autoDispose<FullResult>((ref) {
  final inputs = ref.watch(calculatorControllerProvider).inputs;
  return ref.watch(calculationsRepositoryProvider).full(inputs);
});
