import 'dart:math' as math;

import '../domain/calculation_inputs.dart';

/// Local mirror of the engine for INSTANT visual feedback only (spec §62).
/// The backend remains authoritative; the result screen always uses backend output.
class LocalCalc {
  static double annualCost(CostInputs c) =>
      c.tuitionAnnual +
      c.housingAnnual +
      c.foodAnnual +
      c.booksAnnual +
      c.transportationAnnual +
      c.otherAnnual;

  static double totalCost(CostInputs c) => annualCost(c) * c.programYears;

  static double totalFunding(FundingInputs f) =>
      f.scholarships +
      f.grants +
      f.savings +
      f.familyContribution +
      f.assistantship +
      f.employerContribution +
      f.otherFunding;

  static double fundingGap(CalculationInputs i) =>
      math.max(0, totalCost(i.costs) - totalFunding(i.funding));

  static double principal(CalculationInputs i) =>
      i.loan.loanPrincipalOverride ?? fundingGap(i);

  static double monthlyPayment(CalculationInputs i) {
    final p = principal(i);
    final n = i.loan.repaymentYears * 12;
    if (p <= 0 || n <= 0) return 0;
    final rate = i.loan.annualInterestRate;
    if (rate > 0) {
      final r = rate / 12 / 100;
      final pow = math.pow(1 + r, n).toDouble();
      return p * r * pow / (pow - 1);
    }
    return p / n;
  }

  static double monthlyTakeHome(CareerInputs c) =>
      c.startingSalary / 12 * c.takeHomeRate;

  static double debtBurden(CalculationInputs i) {
    final th = monthlyTakeHome(i.career);
    if (th <= 0) return monthlyPayment(i) > 0 ? 100 : 0;
    return monthlyPayment(i) / th * 100;
  }
}
