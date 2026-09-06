import {
  CalculationConfig,
  DEFAULT_CALCULATION_CONFIG,
} from './calculation.config';
import {
  CalculationInputs,
  CareerInputs,
  CareerResult,
  CostInputs,
  CostResult,
  DebtBurdenResult,
  FullCalculationResult,
  FundingInputs,
  FundingResult,
  LoanInputs,
  LoanResult,
  ScenarioDifference,
  ScoreFactor,
  ScoreResult,
  WhatIfResult,
} from './calculation.types';
import { D, Decimal, dClampMin0, dSum, money, pct } from './money';

/**
 * The STEMWISE calculation engine — the authoritative source of truth (spec §62).
 *
 * Every function is pure and deterministic: results derive ONLY from inputs and
 * the (configurable) planning config. No hardcoded financial results, no reliance
 * on JS floating point (all math via Decimal.js), rounding applied only on output.
 */
export class CalculationEngine {
  constructor(
    private readonly config: CalculationConfig = DEFAULT_CALCULATION_CONFIG,
  ) {}

  // ── Cost (spec §16) ────────────────────────────────────────────────────────
  cost(input: CostInputs): CostResult {
    const annual = dSum([
      input.tuitionAnnual,
      input.housingAnnual,
      input.foodAnnual,
      input.booksAnnual,
      input.transportationAnnual,
      input.otherAnnual,
    ]);
    const total = annual.times(D(input.programYears));

    const tuition = D(input.tuitionAnnual);
    const tuitionShare = annual.isZero()
      ? D(0)
      : tuition.div(annual).times(100);
    const livingShare = annual.isZero() ? D(0) : D(100).minus(tuitionShare);

    return {
      annualCost: money(annual),
      totalEducationCost: money(total),
      tuitionShare: pct(tuitionShare),
      livingCostShare: pct(livingShare),
    };
  }

  // ── Funding (spec §17) ──────────────────────────────────────────────────────
  funding(input: FundingInputs, totalEducationCost: Decimal): FundingResult {
    const totalFunding = dSum([
      input.scholarships,
      input.grants,
      input.savings,
      input.familyContribution,
      input.assistantship,
      input.employerContribution,
      input.otherFunding,
    ]);
    const gap = dClampMin0(totalEducationCost.minus(totalFunding));
    return {
      totalNonLoanFunding: money(totalFunding),
      fundingGap: money(gap),
    };
  }

  // ── Loan amortization (spec §19) ────────────────────────────────────────────
  loan(input: LoanInputs, fundingGap: Decimal): LoanResult {
    const principal =
      input.loanPrincipalOverride != null
        ? D(input.loanPrincipalOverride)
        : fundingGap;

    const n = D(input.repaymentYears).times(12);
    const numberOfPayments = n.toNumber();
    const annualRate = D(input.annualInterestRate);

    let monthlyPayment: Decimal;
    if (principal.lessThanOrEqualTo(0) || n.lessThanOrEqualTo(0)) {
      monthlyPayment = D(0);
    } else if (annualRate.greaterThan(0)) {
      // r = annualRate / 12 / 100
      const r = annualRate.div(12).div(100);
      const onePlusRpowN = r.plus(1).pow(numberOfPayments);
      // P * r * (1+r)^n / ((1+r)^n - 1)
      monthlyPayment = principal
        .times(r)
        .times(onePlusRpowN)
        .div(onePlusRpowN.minus(1));
    } else {
      monthlyPayment = principal.div(n);
    }

    const totalRepayment = monthlyPayment.times(n);
    const totalInterest = dClampMin0(totalRepayment.minus(principal));

    return {
      principal: money(principal),
      monthlyPayment: money(monthlyPayment),
      totalRepayment: money(totalRepayment),
      totalInterest: money(totalInterest),
      numberOfPayments,
      annualInterestRate: annualRate.toNumber(),
      repaymentYears: input.repaymentYears,
    };
  }

  // ── Career / take-home (spec §21, §22) ──────────────────────────────────────
  career(input: CareerInputs): CareerResult {
    const salary = D(input.startingSalary);
    const takeHomeRate = D(input.takeHomeRate);
    const monthlyGross = salary.div(12);
    const monthlyTakeHome = monthlyGross.times(takeHomeRate);
    return {
      startingSalary: money(salary),
      monthlyGross: money(monthlyGross),
      monthlyTakeHome: money(monthlyTakeHome),
      takeHomeRate: input.takeHomeRate,
    };
  }

  // ── Debt burden (spec §23) ──────────────────────────────────────────────────
  debtBurden(
    monthlyPayment: Decimal,
    monthlyTakeHome: Decimal,
  ): DebtBurdenResult {
    const t = this.config.debtBurdenThresholds;
    let burden: Decimal;
    if (monthlyTakeHome.lessThanOrEqualTo(0)) {
      // No income to service debt: max burden if there is any payment.
      burden = monthlyPayment.greaterThan(0) ? D(100) : D(0);
    } else {
      burden = monthlyPayment.div(monthlyTakeHome).times(100);
    }

    const b = burden.toNumber();
    let band: DebtBurdenResult['band'];
    if (b < t.lowMax) band = 'low';
    else if (b < t.moderateMax) band = 'moderate';
    else if (b < t.elevatedMax) band = 'elevated';
    else band = 'high';

    return {
      loanPaymentBurden: pct(burden),
      band,
      monthlyRemaining: money(monthlyTakeHome.minus(monthlyPayment)),
    };
  }

  // ── Score engine (spec §24, §25) ────────────────────────────────────────────
  score(params: {
    totalEducationCost: Decimal;
    totalNonLoanFunding: Decimal;
    principal: Decimal;
    loanPaymentBurden: Decimal;
    startingSalary: Decimal;
  }): ScoreResult {
    const w = this.config.scoreWeights;
    const norm = this.config.scoreNormalization;
    const salary = params.startingSalary;

    const clamp01 = (v: Decimal): Decimal =>
      Decimal.max(0, Decimal.min(1, v));

    // Cost pressure: lower total-cost-to-income is healthier.
    const costRatio = salary.lessThanOrEqualTo(0)
      ? D(norm.costToIncomeRatioCeiling)
      : params.totalEducationCost.div(salary);
    const costNorm = clamp01(
      D(1).minus(costRatio.div(norm.costToIncomeRatioCeiling)),
    );

    // Debt: lower borrowing-to-income is healthier.
    const debtRatio = salary.lessThanOrEqualTo(0)
      ? D(norm.debtToIncomeRatioCeiling)
      : params.principal.div(salary);
    const debtNorm = clamp01(
      D(1).minus(debtRatio.div(norm.debtToIncomeRatioCeiling)),
    );

    // Payment burden: lower % of take-home is healthier.
    const burdenNorm = clamp01(
      D(1).minus(params.loanPaymentBurden.div(norm.paymentBurdenCeiling)),
    );

    // Income: higher starting salary is healthier (floor..reference).
    const incomeNorm = clamp01(
      salary
        .minus(norm.incomeFloor)
        .div(D(norm.incomeReference).minus(norm.incomeFloor)),
    );

    // Funding: higher share of cost covered without loans is healthier.
    const fundingNorm = params.totalEducationCost.lessThanOrEqualTo(0)
      ? D(1)
      : clamp01(params.totalNonLoanFunding.div(params.totalEducationCost));

    const rawFactors: Array<
      Omit<ScoreFactor, 'contribution'> & { normalizedD: Decimal; weight: number }
    > = [
      {
        key: 'costPressure',
        label: 'Education cost pressure',
        normalizedD: costNorm,
        normalized: pct(costNorm, 3),
        weight: w.costPressure,
        explanation:
          'Compares total estimated education cost to expected starting salary. Lower relative cost scores higher.',
      },
      {
        key: 'debt',
        label: 'Projected borrowing',
        normalizedD: debtNorm,
        normalized: pct(debtNorm, 3),
        weight: w.debt,
        explanation:
          'Compares projected borrowing to expected starting salary. Less borrowing relative to income scores higher.',
      },
      {
        key: 'paymentBurden',
        label: 'Monthly payment burden',
        normalizedD: burdenNorm,
        normalized: pct(burdenNorm, 3),
        weight: w.paymentBurden,
        explanation:
          'Estimated monthly loan payment as a share of estimated take-home income. A lower share scores higher.',
      },
      {
        key: 'income',
        label: 'Expected income',
        normalizedD: incomeNorm,
        normalized: pct(incomeNorm, 3),
        weight: w.income,
        explanation:
          'Expected starting salary for the selected field. A higher expected salary scores higher.',
      },
      {
        key: 'funding',
        label: 'Non-loan funding coverage',
        normalizedD: fundingNorm,
        normalized: pct(fundingNorm, 3),
        weight: w.funding,
        explanation:
          'Share of total education cost covered by scholarships, grants, savings and other non-loan funding.',
      },
    ];

    let scoreD = D(0);
    const factors: ScoreFactor[] = rawFactors.map((f) => {
      const contributionD = f.normalizedD.times(f.weight).times(100);
      scoreD = scoreD.plus(contributionD);
      return {
        key: f.key,
        label: f.label,
        normalized: f.normalized,
        weight: f.weight,
        contribution: pct(contributionD, 2),
        explanation: f.explanation,
      };
    });

    const score = Math.round(scoreD.toNumber());
    let classification: ScoreResult['classification'];
    let classificationLabel: string;
    if (score >= 80) {
      classification = 'strong';
      classificationLabel = 'Strong position';
    } else if (score >= 60) {
      classification = 'manageable';
      classificationLabel = 'Relatively manageable';
    } else if (score >= 40) {
      classification = 'attention';
      classificationLabel = 'Needs attention';
    } else {
      classification = 'pressure';
      classificationLabel = 'High financial pressure';
    }

    return { score, classification, classificationLabel, factors };
  }

  // ── Full model (spec §63) ───────────────────────────────────────────────────
  full(input: CalculationInputs): FullCalculationResult {
    const cost = this.cost(input.costs);
    const totalEducationCost = D(cost.totalEducationCost);

    const funding = this.funding(input.funding, totalEducationCost);
    const fundingGap = D(funding.fundingGap);

    const loan = this.loan(input.loan, fundingGap);
    const career = this.career(input.career);

    const debtBurden = this.debtBurden(
      D(loan.monthlyPayment),
      D(career.monthlyTakeHome),
    );

    const score = this.score({
      totalEducationCost,
      totalNonLoanFunding: D(funding.totalNonLoanFunding),
      principal: D(loan.principal),
      loanPaymentBurden: D(debtBurden.loanPaymentBurden),
      startingSalary: D(career.startingSalary),
    });

    return { cost, funding, loan, career, debtBurden, score };
  }

  // ── What-if (spec §64) ──────────────────────────────────────────────────────
  whatIf(
    baselineInputs: CalculationInputs,
    scenarioInputs: CalculationInputs,
  ): WhatIfResult {
    const baseline = this.full(baselineInputs);
    const scenario = this.full(scenarioInputs);

    const diff = (
      field: string,
      label: string,
      a: number,
      b: number,
      lowerIsBetter: boolean,
    ): ScenarioDifference => {
      const delta = +(b - a).toFixed(2);
      let direction: ScenarioDifference['direction'];
      if (delta === 0) direction = 'unchanged';
      else if (lowerIsBetter) direction = delta < 0 ? 'improvement' : 'worsening';
      else direction = delta > 0 ? 'improvement' : 'worsening';
      return { field, label, baseline: a, scenario: b, delta, direction };
    };

    const differences: ScenarioDifference[] = [
      diff('totalEducationCost', 'Total cost', baseline.cost.totalEducationCost, scenario.cost.totalEducationCost, true),
      diff('totalNonLoanFunding', 'Funding', baseline.funding.totalNonLoanFunding, scenario.funding.totalNonLoanFunding, false),
      diff('principal', 'Projected borrowing', baseline.loan.principal, scenario.loan.principal, true),
      diff('monthlyPayment', 'Monthly payment', baseline.loan.monthlyPayment, scenario.loan.monthlyPayment, true),
      diff('totalInterest', 'Total interest', baseline.loan.totalInterest, scenario.loan.totalInterest, true),
      diff('startingSalary', 'Starting salary', baseline.career.startingSalary, scenario.career.startingSalary, false),
      diff('loanPaymentBurden', 'Debt burden', baseline.debtBurden.loanPaymentBurden, scenario.debtBurden.loanPaymentBurden, true),
      diff('score', 'Planning score', baseline.score.score, scenario.score.score, false),
    ];

    return { baseline, scenario, differences };
  }
}
