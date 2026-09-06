import 'package:flutter_test/flutter_test.dart';
import 'package:stemwise/features/calculator/application/local_calc.dart';
import 'package:stemwise/features/calculator/domain/calculation_inputs.dart';

void main() {
  final inputs = CalculationInputs(
    costs: const CostInputs(
      tuitionAnnual: 20000,
      housingAnnual: 8000,
      foodAnnual: 4000,
      booksAnnual: 1200,
      transportationAnnual: 1000,
      otherAnnual: 1800,
      programYears: 4,
    ),
    funding: const FundingInputs(
      scholarships: 15000,
      grants: 5000,
      savings: 10000,
      familyContribution: 5000,
    ),
    loan: const LoanInputs(annualInterestRate: 6.5, repaymentYears: 10),
    career: const CareerInputs(startingSalary: 85000, takeHomeRate: 0.7),
  );

  test('local mirror matches spec §89 (instant-feedback preview)', () {
    expect(LocalCalc.annualCost(inputs.costs), 36000);
    expect(LocalCalc.totalCost(inputs.costs), 144000);
    expect(LocalCalc.fundingGap(inputs), 109000);
  });

  test('zero-interest loan divides principal evenly', () {
    final i = inputs.copyWith(
      loan: const LoanInputs(annualInterestRate: 0, repaymentYears: 5, loanPrincipalOverride: 12000),
    );
    expect(LocalCalc.monthlyPayment(i), 200);
  });

  test('positive-interest loan uses amortization', () {
    final i = inputs.copyWith(
      loan: const LoanInputs(annualInterestRate: 6, repaymentYears: 10, loanPrincipalOverride: 10000),
    );
    expect(LocalCalc.monthlyPayment(i), closeTo(111.02, 0.1));
  });
}
