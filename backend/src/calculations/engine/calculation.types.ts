/**
 * Canonical calculation input/output shapes for the STEMWISE engine.
 *
 * `CalculationInputs` is the AUTHORITATIVE source of truth (spec §54, §62).
 * All results are derived from it; nothing is hardcoded.
 */

export interface CostInputs {
  tuitionAnnual: number;
  housingAnnual: number;
  foodAnnual: number;
  booksAnnual: number;
  transportationAnnual: number;
  otherAnnual: number;
  programYears: number;
}

export interface FundingInputs {
  scholarships: number;
  grants: number;
  savings: number;
  familyContribution: number;
  assistantship: number;
  employerContribution: number;
  otherFunding: number;
}

export interface LoanInputs {
  /** Optional manual override. If omitted/null, the funding gap is used (spec §18). */
  loanPrincipalOverride?: number | null;
  annualInterestRate: number; // percent, e.g. 6.5
  repaymentYears: number;
}

export interface CareerInputs {
  startingSalary: number;
  /** Fraction of gross kept after tax/deductions, e.g. 0.70 (spec §22). */
  takeHomeRate: number;
}

export interface CalculationInputs {
  costs: CostInputs;
  funding: FundingInputs;
  loan: LoanInputs;
  career: CareerInputs;
}

export interface CostResult {
  annualCost: number;
  totalEducationCost: number;
  tuitionShare: number; // % of annual cost
  livingCostShare: number; // % of annual cost (everything except tuition)
}

export interface FundingResult {
  totalNonLoanFunding: number;
  fundingGap: number;
}

export interface LoanResult {
  principal: number;
  monthlyPayment: number;
  totalRepayment: number;
  totalInterest: number;
  numberOfPayments: number;
  annualInterestRate: number;
  repaymentYears: number;
}

export interface CareerResult {
  startingSalary: number;
  monthlyGross: number;
  monthlyTakeHome: number;
  takeHomeRate: number;
}

export interface DebtBurdenResult {
  loanPaymentBurden: number; // % of monthly take-home
  band: 'low' | 'moderate' | 'elevated' | 'high';
  monthlyRemaining: number; // take-home minus loan payment
}

export interface ScoreFactor {
  key: string;
  label: string;
  /** Normalized 0..1 (1 = best/healthiest). */
  normalized: number;
  weight: number;
  /** Weighted contribution to the 0..100 score. */
  contribution: number;
  explanation: string;
}

export interface ScoreResult {
  score: number; // 0..100
  classification: 'strong' | 'manageable' | 'attention' | 'pressure';
  classificationLabel: string;
  factors: ScoreFactor[];
}

export interface FullCalculationResult {
  cost: CostResult;
  funding: FundingResult;
  loan: LoanResult;
  career: CareerResult;
  debtBurden: DebtBurdenResult;
  score: ScoreResult;
}

export interface ScenarioDifference<T = number> {
  field: string;
  label: string;
  baseline: T;
  scenario: T;
  delta: number;
  /** Direction relative to the user's financial health, not raw sign. */
  direction: 'improvement' | 'worsening' | 'unchanged';
}

export interface WhatIfResult {
  baseline: FullCalculationResult;
  scenario: FullCalculationResult;
  differences: ScenarioDifference[];
}
