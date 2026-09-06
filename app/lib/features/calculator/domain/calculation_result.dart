/// Result models mirroring the backend calculation output (spec §63, §65).
class FullResult {
  final CostResult cost;
  final FundingResult funding;
  final LoanResult loan;
  final CareerResult career;
  final DebtBurdenResult debtBurden;
  final ScoreResult score;
  final List<Recommendation> recommendations;

  FullResult({
    required this.cost,
    required this.funding,
    required this.loan,
    required this.career,
    required this.debtBurden,
    required this.score,
    required this.recommendations,
  });

  factory FullResult.fromJson(Map<String, dynamic> j) => FullResult(
        cost: CostResult.fromJson(j['cost']),
        funding: FundingResult.fromJson(j['funding']),
        loan: LoanResult.fromJson(j['loan']),
        career: CareerResult.fromJson(j['career']),
        debtBurden: DebtBurdenResult.fromJson(j['debtBurden']),
        score: ScoreResult.fromJson(j['score']),
        recommendations: ((j['recommendations'] ?? []) as List)
            .map((e) => Recommendation.fromJson(e))
            .toList(),
      );
}

class CostResult {
  final double annualCost, totalEducationCost, tuitionShare, livingCostShare;
  CostResult(this.annualCost, this.totalEducationCost, this.tuitionShare,
      this.livingCostShare);
  factory CostResult.fromJson(Map<String, dynamic> j) => CostResult(
        (j['annualCost'] ?? 0).toDouble(),
        (j['totalEducationCost'] ?? 0).toDouble(),
        (j['tuitionShare'] ?? 0).toDouble(),
        (j['livingCostShare'] ?? 0).toDouble(),
      );
}

class FundingResult {
  final double totalNonLoanFunding, fundingGap;
  FundingResult(this.totalNonLoanFunding, this.fundingGap);
  factory FundingResult.fromJson(Map<String, dynamic> j) => FundingResult(
        (j['totalNonLoanFunding'] ?? 0).toDouble(),
        (j['fundingGap'] ?? 0).toDouble(),
      );
}

class LoanResult {
  final double principal, monthlyPayment, totalRepayment, totalInterest;
  final int numberOfPayments, repaymentYears;
  final double annualInterestRate;
  LoanResult(this.principal, this.monthlyPayment, this.totalRepayment,
      this.totalInterest, this.numberOfPayments, this.repaymentYears,
      this.annualInterestRate);
  factory LoanResult.fromJson(Map<String, dynamic> j) => LoanResult(
        (j['principal'] ?? 0).toDouble(),
        (j['monthlyPayment'] ?? 0).toDouble(),
        (j['totalRepayment'] ?? 0).toDouble(),
        (j['totalInterest'] ?? 0).toDouble(),
        (j['numberOfPayments'] ?? 0).toInt(),
        (j['repaymentYears'] ?? 0).toInt(),
        (j['annualInterestRate'] ?? 0).toDouble(),
      );
}

class CareerResult {
  final double startingSalary, monthlyGross, monthlyTakeHome, takeHomeRate;
  CareerResult(this.startingSalary, this.monthlyGross, this.monthlyTakeHome,
      this.takeHomeRate);
  factory CareerResult.fromJson(Map<String, dynamic> j) => CareerResult(
        (j['startingSalary'] ?? 0).toDouble(),
        (j['monthlyGross'] ?? 0).toDouble(),
        (j['monthlyTakeHome'] ?? 0).toDouble(),
        (j['takeHomeRate'] ?? 0).toDouble(),
      );
}

class DebtBurdenResult {
  final double loanPaymentBurden, monthlyRemaining;
  final String band;
  DebtBurdenResult(this.loanPaymentBurden, this.band, this.monthlyRemaining);
  factory DebtBurdenResult.fromJson(Map<String, dynamic> j) => DebtBurdenResult(
        (j['loanPaymentBurden'] ?? 0).toDouble(),
        (j['band'] ?? 'low') as String,
        (j['monthlyRemaining'] ?? 0).toDouble(),
      );
}

class ScoreFactor {
  final String key, label, explanation;
  final double normalized, weight, contribution;
  ScoreFactor(this.key, this.label, this.explanation, this.normalized,
      this.weight, this.contribution);
  factory ScoreFactor.fromJson(Map<String, dynamic> j) => ScoreFactor(
        j['key'] as String,
        j['label'] as String,
        j['explanation'] as String,
        (j['normalized'] ?? 0).toDouble(),
        (j['weight'] ?? 0).toDouble(),
        (j['contribution'] ?? 0).toDouble(),
      );
}

class ScoreResult {
  final int score;
  final String classification, classificationLabel;
  final List<ScoreFactor> factors;
  ScoreResult(this.score, this.classification, this.classificationLabel,
      this.factors);
  factory ScoreResult.fromJson(Map<String, dynamic> j) => ScoreResult(
        (j['score'] ?? 0).toInt(),
        (j['classification'] ?? '') as String,
        (j['classificationLabel'] ?? '') as String,
        ((j['factors'] ?? []) as List)
            .map((e) => ScoreFactor.fromJson(e))
            .toList(),
      );
}

class Recommendation {
  final String key, title, description, affectedVariable, estimatedImpact;
  final int priority;
  Recommendation(this.key, this.title, this.description, this.affectedVariable,
      this.estimatedImpact, this.priority);
  factory Recommendation.fromJson(Map<String, dynamic> j) => Recommendation(
        j['key'] as String,
        j['title'] as String,
        j['description'] as String,
        (j['affectedVariable'] ?? '') as String,
        (j['estimatedImpact'] ?? '') as String,
        (j['priority'] ?? 0).toInt(),
      );
}

/// One what-if difference row (spec §31, §64).
class ScenarioDifference {
  final String field, label, direction;
  final double baseline, scenario, delta;
  ScenarioDifference(this.field, this.label, this.direction, this.baseline,
      this.scenario, this.delta);
  factory ScenarioDifference.fromJson(Map<String, dynamic> j) =>
      ScenarioDifference(
        j['field'] as String,
        j['label'] as String,
        j['direction'] as String,
        (j['baseline'] ?? 0).toDouble(),
        (j['scenario'] ?? 0).toDouble(),
        (j['delta'] ?? 0).toDouble(),
      );
}

class WhatIfResult {
  final FullResult baseline, scenario;
  final List<ScenarioDifference> differences;
  WhatIfResult(this.baseline, this.scenario, this.differences);
  factory WhatIfResult.fromJson(Map<String, dynamic> j) => WhatIfResult(
        FullResult.fromJson(j['baseline']),
        FullResult.fromJson(j['scenario']),
        ((j['differences'] ?? []) as List)
            .map((e) => ScenarioDifference.fromJson(e))
            .toList(),
      );
}
