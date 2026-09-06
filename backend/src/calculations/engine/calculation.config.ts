/**
 * Configurable calculation parameters (spec §23, §24, §25, §107).
 *
 * These are STEMWISE PLANNING assumptions, not universal financial rules.
 * They live in one place so weights/thresholds are never scattered through the
 * codebase and can later be overridden per-request or from the DB
 * (calculation_configs collection, spec §48).
 */

export interface DebtBurdenThresholds {
  /** Upper bound (%) for each band; anything above `elevatedMax` is "high". */
  lowMax: number; // < lowMax => low
  moderateMax: number; // < moderateMax => moderate
  elevatedMax: number; // < elevatedMax => elevated, else high
}

export interface ScoreWeights {
  costPressure: number;
  debt: number;
  paymentBurden: number;
  income: number;
  funding: number;
}

export interface ScoreNormalization {
  /**
   * Reference ceilings used to normalize raw values to 0..1.
   * Chosen as reasonable planning references; fully configurable.
   */
  costToIncomeRatioCeiling: number; // totalCost / annualSalary considered "maxed"
  debtToIncomeRatioCeiling: number; // principal / annualSalary considered "maxed"
  paymentBurdenCeiling: number; // % burden considered "maxed"
  incomeReference: number; // salary at/above which income factor is ~full
  incomeFloor: number; // salary at/below which income factor is ~0
}

export interface CalculationConfig {
  defaultTakeHomeRate: number;
  defaultAnnualInterestRate: number;
  defaultRepaymentYears: number;
  interestRateAsOf: string; // ISO date — "example planning rate, last updated" (spec §18)
  debtBurdenThresholds: DebtBurdenThresholds;
  scoreWeights: ScoreWeights;
  scoreNormalization: ScoreNormalization;
  limits: {
    interestRateMax: number;
    programYearsMin: number;
    programYearsMax: number;
    salaryMax: number;
  };
}

export const DEFAULT_CALCULATION_CONFIG: CalculationConfig = {
  defaultTakeHomeRate: 0.7,
  defaultAnnualInterestRate: 6.5,
  defaultRepaymentYears: 10,
  interestRateAsOf: '2026-01-01',
  debtBurdenThresholds: {
    lowMax: 10,
    moderateMax: 20,
    elevatedMax: 30,
  },
  scoreWeights: {
    costPressure: 0.2,
    debt: 0.25,
    paymentBurden: 0.25,
    income: 0.2,
    funding: 0.1,
  },
  scoreNormalization: {
    costToIncomeRatioCeiling: 3, // total cost = 3x annual salary => full pressure
    debtToIncomeRatioCeiling: 1.5, // borrowing = 1.5x annual salary => full pressure
    paymentBurdenCeiling: 40, // 40% of take-home => full pressure
    incomeReference: 100000,
    incomeFloor: 30000,
  },
  limits: {
    interestRateMax: 30,
    programYearsMin: 1,
    programYearsMax: 10,
    salaryMax: 10_000_000,
  },
};
