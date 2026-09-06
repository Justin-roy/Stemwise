import 'dart:convert';

/// Authoritative user inputs (spec §54, §63). Mirrors the backend DTO exactly.
class CalculationInputs {
  final CostInputs costs;
  final FundingInputs funding;
  final LoanInputs loan;
  final CareerInputs career;

  const CalculationInputs({
    required this.costs,
    required this.funding,
    required this.loan,
    required this.career,
  });

  factory CalculationInputs.initial() => const CalculationInputs(
        costs: CostInputs(),
        funding: FundingInputs(),
        loan: LoanInputs(),
        career: CareerInputs(),
      );

  CalculationInputs copyWith({
    CostInputs? costs,
    FundingInputs? funding,
    LoanInputs? loan,
    CareerInputs? career,
  }) =>
      CalculationInputs(
        costs: costs ?? this.costs,
        funding: funding ?? this.funding,
        loan: loan ?? this.loan,
        career: career ?? this.career,
      );

  Map<String, dynamic> toJson() => {
        'costs': costs.toJson(),
        'funding': funding.toJson(),
        'loan': loan.toJson(),
        'career': career.toJson(),
      };

  factory CalculationInputs.fromJson(Map<String, dynamic> j) => CalculationInputs(
        costs: CostInputs.fromJson(j['costs'] ?? {}),
        funding: FundingInputs.fromJson(j['funding'] ?? {}),
        loan: LoanInputs.fromJson(j['loan'] ?? {}),
        career: CareerInputs.fromJson(j['career'] ?? {}),
      );

  String encode() => jsonEncode(toJson());
  static CalculationInputs decode(String s) =>
      CalculationInputs.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

class CostInputs {
  final double tuitionAnnual;
  final double housingAnnual;
  final double foodAnnual;
  final double booksAnnual;
  final double transportationAnnual;
  final double otherAnnual;
  final int programYears;

  const CostInputs({
    this.tuitionAnnual = 0,
    this.housingAnnual = 0,
    this.foodAnnual = 0,
    this.booksAnnual = 0,
    this.transportationAnnual = 0,
    this.otherAnnual = 0,
    this.programYears = 4,
  });

  CostInputs copyWith({
    double? tuitionAnnual,
    double? housingAnnual,
    double? foodAnnual,
    double? booksAnnual,
    double? transportationAnnual,
    double? otherAnnual,
    int? programYears,
  }) =>
      CostInputs(
        tuitionAnnual: tuitionAnnual ?? this.tuitionAnnual,
        housingAnnual: housingAnnual ?? this.housingAnnual,
        foodAnnual: foodAnnual ?? this.foodAnnual,
        booksAnnual: booksAnnual ?? this.booksAnnual,
        transportationAnnual: transportationAnnual ?? this.transportationAnnual,
        otherAnnual: otherAnnual ?? this.otherAnnual,
        programYears: programYears ?? this.programYears,
      );

  Map<String, dynamic> toJson() => {
        'tuitionAnnual': tuitionAnnual,
        'housingAnnual': housingAnnual,
        'foodAnnual': foodAnnual,
        'booksAnnual': booksAnnual,
        'transportationAnnual': transportationAnnual,
        'otherAnnual': otherAnnual,
        'programYears': programYears,
      };

  factory CostInputs.fromJson(Map<String, dynamic> j) => CostInputs(
        tuitionAnnual: (j['tuitionAnnual'] ?? 0).toDouble(),
        housingAnnual: (j['housingAnnual'] ?? 0).toDouble(),
        foodAnnual: (j['foodAnnual'] ?? 0).toDouble(),
        booksAnnual: (j['booksAnnual'] ?? 0).toDouble(),
        transportationAnnual: (j['transportationAnnual'] ?? 0).toDouble(),
        otherAnnual: (j['otherAnnual'] ?? 0).toDouble(),
        programYears: (j['programYears'] ?? 4).toInt(),
      );
}

class FundingInputs {
  final double scholarships;
  final double grants;
  final double savings;
  final double familyContribution;
  final double assistantship;
  final double employerContribution;
  final double otherFunding;

  const FundingInputs({
    this.scholarships = 0,
    this.grants = 0,
    this.savings = 0,
    this.familyContribution = 0,
    this.assistantship = 0,
    this.employerContribution = 0,
    this.otherFunding = 0,
  });

  FundingInputs copyWith({
    double? scholarships,
    double? grants,
    double? savings,
    double? familyContribution,
    double? assistantship,
    double? employerContribution,
    double? otherFunding,
  }) =>
      FundingInputs(
        scholarships: scholarships ?? this.scholarships,
        grants: grants ?? this.grants,
        savings: savings ?? this.savings,
        familyContribution: familyContribution ?? this.familyContribution,
        assistantship: assistantship ?? this.assistantship,
        employerContribution: employerContribution ?? this.employerContribution,
        otherFunding: otherFunding ?? this.otherFunding,
      );

  Map<String, dynamic> toJson() => {
        'scholarships': scholarships,
        'grants': grants,
        'savings': savings,
        'familyContribution': familyContribution,
        'assistantship': assistantship,
        'employerContribution': employerContribution,
        'otherFunding': otherFunding,
      };

  factory FundingInputs.fromJson(Map<String, dynamic> j) => FundingInputs(
        scholarships: (j['scholarships'] ?? 0).toDouble(),
        grants: (j['grants'] ?? 0).toDouble(),
        savings: (j['savings'] ?? 0).toDouble(),
        familyContribution: (j['familyContribution'] ?? 0).toDouble(),
        assistantship: (j['assistantship'] ?? 0).toDouble(),
        employerContribution: (j['employerContribution'] ?? 0).toDouble(),
        otherFunding: (j['otherFunding'] ?? 0).toDouble(),
      );
}

class LoanInputs {
  final double? loanPrincipalOverride;
  final double annualInterestRate;
  final int repaymentYears;

  const LoanInputs({
    this.loanPrincipalOverride,
    this.annualInterestRate = 6.5,
    this.repaymentYears = 10,
  });

  LoanInputs copyWith({
    double? loanPrincipalOverride,
    bool clearOverride = false,
    double? annualInterestRate,
    int? repaymentYears,
  }) =>
      LoanInputs(
        loanPrincipalOverride:
            clearOverride ? null : (loanPrincipalOverride ?? this.loanPrincipalOverride),
        annualInterestRate: annualInterestRate ?? this.annualInterestRate,
        repaymentYears: repaymentYears ?? this.repaymentYears,
      );

  Map<String, dynamic> toJson() => {
        'loanPrincipalOverride': loanPrincipalOverride,
        'annualInterestRate': annualInterestRate,
        'repaymentYears': repaymentYears,
      };

  factory LoanInputs.fromJson(Map<String, dynamic> j) => LoanInputs(
        loanPrincipalOverride: (j['loanPrincipalOverride'] as num?)?.toDouble(),
        annualInterestRate: (j['annualInterestRate'] ?? 6.5).toDouble(),
        repaymentYears: (j['repaymentYears'] ?? 10).toInt(),
      );
}

class CareerInputs {
  final double startingSalary;
  final double takeHomeRate;

  const CareerInputs({this.startingSalary = 0, this.takeHomeRate = 0.7});

  CareerInputs copyWith({double? startingSalary, double? takeHomeRate}) =>
      CareerInputs(
        startingSalary: startingSalary ?? this.startingSalary,
        takeHomeRate: takeHomeRate ?? this.takeHomeRate,
      );

  Map<String, dynamic> toJson() => {
        'startingSalary': startingSalary,
        'takeHomeRate': takeHomeRate,
      };

  factory CareerInputs.fromJson(Map<String, dynamic> j) => CareerInputs(
        startingSalary: (j['startingSalary'] ?? 0).toDouble(),
        takeHomeRate: (j['takeHomeRate'] ?? 0.7).toDouble(),
      );
}
