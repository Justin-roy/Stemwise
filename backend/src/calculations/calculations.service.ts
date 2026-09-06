import { Injectable } from '@nestjs/common';
import { DEFAULT_CALCULATION_CONFIG } from './engine/calculation.config';
import { CalculationEngine } from './engine/calculation-engine';
import { RecommendationEngine } from './engine/recommendation-engine';
import { CalculationInputs } from './engine/calculation.types';
import { D } from './engine/money';

/**
 * Thin service wrapping the pure engine so it can be injected and, later,
 * hydrated with per-request or DB-sourced config (calculation_configs, spec §48).
 * The backend is authoritative: it always recalculates from inputs (spec §62).
 */
@Injectable()
export class CalculationsService {
  private readonly engine = new CalculationEngine(DEFAULT_CALCULATION_CONFIG);
  private readonly recommender = new RecommendationEngine();

  get config() {
    return DEFAULT_CALCULATION_CONFIG;
  }

  cost(input: CalculationInputs['costs']) {
    return this.engine.cost(input);
  }

  funding(input: CalculationInputs) {
    const cost = this.engine.cost(input.costs);
    return this.engine.funding(input.funding, D(cost.totalEducationCost));
  }

  loan(input: CalculationInputs) {
    const cost = this.engine.cost(input.costs);
    const funding = this.engine.funding(input.funding, D(cost.totalEducationCost));
    return this.engine.loan(input.loan, D(funding.fundingGap));
  }

  career(input: CalculationInputs['career']) {
    return this.engine.career(input);
  }

  full(input: CalculationInputs) {
    const result = this.engine.full(input);
    const recommendations = this.recommender.generate(input, result);
    return { ...result, recommendations };
  }

  whatIf(baseline: CalculationInputs, scenario: CalculationInputs) {
    return this.engine.whatIf(baseline, scenario);
  }

  /** Exposes the planning assumptions used, for transparency (spec §107). */
  assumptions() {
    const c = this.config;
    return {
      takeHomeRate: c.defaultTakeHomeRate,
      exampleAnnualInterestRate: c.defaultAnnualInterestRate,
      interestRateAsOf: c.interestRateAsOf,
      defaultRepaymentYears: c.defaultRepaymentYears,
      debtBurdenThresholds: c.debtBurdenThresholds,
      scoreWeights: c.scoreWeights,
      disclaimer:
        'STEMWISE provides educational estimates for planning purposes only. It is not a lender, financial advisor, admissions service, or guarantee of future income, employment, loan approval, or repayment outcomes. Actual costs, financial aid, interest rates, taxes, salaries, and repayment terms may differ.',
    };
  }
}
