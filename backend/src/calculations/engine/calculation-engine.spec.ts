import { CalculationEngine } from './calculation-engine';
import { CalculationInputs } from './calculation.types';

const engine = new CalculationEngine();

const baseInputs = (over: Partial<CalculationInputs> = {}): CalculationInputs => ({
  costs: {
    tuitionAnnual: 20000,
    housingAnnual: 8000,
    foodAnnual: 4000,
    booksAnnual: 1200,
    transportationAnnual: 1000,
    otherAnnual: 1800,
    programYears: 4,
  },
  funding: {
    scholarships: 15000,
    grants: 5000,
    savings: 10000,
    familyContribution: 5000,
    assistantship: 0,
    employerContribution: 0,
    otherFunding: 0,
  },
  loan: { loanPrincipalOverride: null, annualInterestRate: 6.5, repaymentYears: 10 },
  career: { startingSalary: 85000, takeHomeRate: 0.7 },
  ...over,
});

describe('CalculationEngine — cost (§16, §89 critical test)', () => {
  it('computes annual and total cost from inputs, not approximations', () => {
    const r = engine.cost(baseInputs().costs);
    expect(r.annualCost).toBe(36000);
    expect(r.totalEducationCost).toBe(144000); // 36,000 × 4 — spec §89
  });

  it('computes tuition vs living-cost share', () => {
    const r = engine.cost(baseInputs().costs);
    // tuition 20000 / 36000 = 55.6%
    expect(r.tuitionShare).toBeCloseTo(55.6, 1);
    expect(r.livingCostShare).toBeCloseTo(44.4, 1);
  });

  it('handles all-zero costs without dividing by zero', () => {
    const r = engine.cost({
      tuitionAnnual: 0, housingAnnual: 0, foodAnnual: 0, booksAnnual: 0,
      transportationAnnual: 0, otherAnnual: 0, programYears: 2,
    });
    expect(r.annualCost).toBe(0);
    expect(r.totalEducationCost).toBe(0);
    expect(r.tuitionShare).toBe(0);
  });
});

describe('CalculationEngine — funding (§17, §89 critical test)', () => {
  it('computes total non-loan funding and gap', () => {
    const full = engine.full(baseInputs());
    expect(full.funding.totalNonLoanFunding).toBe(35000);
    expect(full.funding.fundingGap).toBe(109000); // 144,000 − 35,000 — spec §89
  });

  it('clamps funding gap to zero when fully funded', () => {
    const full = engine.full(
      baseInputs({
        funding: {
          scholarships: 200000, grants: 0, savings: 0, familyContribution: 0,
          assistantship: 0, employerContribution: 0, otherFunding: 0,
        },
      }),
    );
    expect(full.funding.fundingGap).toBe(0);
    expect(full.loan.principal).toBe(0);
    expect(full.loan.monthlyPayment).toBe(0);
  });
});

describe('CalculationEngine — loan amortization (§19)', () => {
  it('positive interest: standard amortization formula', () => {
    // $10,000 @ 6% for 10y → known value ≈ $111.02/mo
    const r = engine.loan(
      { loanPrincipalOverride: 10000, annualInterestRate: 6, repaymentYears: 10 },
      // funding gap unused because override present
      // @ts-expect-no-error
      undefined as never,
    );
    expect(r.monthlyPayment).toBeCloseTo(111.02, 2);
    expect(r.numberOfPayments).toBe(120);
    expect(r.totalRepayment).toBeCloseTo(13322.46, 1);
    expect(r.totalInterest).toBeCloseTo(3322.46, 1);
  });

  it('zero interest: principal / number of payments', () => {
    const r = engine.loan(
      { loanPrincipalOverride: 12000, annualInterestRate: 0, repaymentYears: 5 },
      undefined as never,
    );
    expect(r.numberOfPayments).toBe(60);
    expect(r.monthlyPayment).toBe(200); // 12000 / 60
    expect(r.totalRepayment).toBe(12000);
    expect(r.totalInterest).toBe(0);
  });

  it('zero loan: no payment, no interest', () => {
    const r = engine.loan(
      { loanPrincipalOverride: 0, annualInterestRate: 6.5, repaymentYears: 10 },
      undefined as never,
    );
    expect(r.monthlyPayment).toBe(0);
    expect(r.totalInterest).toBe(0);
  });

  it('longer term lowers monthly payment but raises total interest', () => {
    const short = engine.loan({ loanPrincipalOverride: 50000, annualInterestRate: 7, repaymentYears: 5 }, undefined as never);
    const long = engine.loan({ loanPrincipalOverride: 50000, annualInterestRate: 7, repaymentYears: 20 }, undefined as never);
    expect(long.monthlyPayment).toBeLessThan(short.monthlyPayment);
    expect(long.totalInterest).toBeGreaterThan(short.totalInterest);
  });

  it('uses funding gap when no override is supplied', () => {
    const full = engine.full(baseInputs());
    expect(full.loan.principal).toBe(109000); // equals funding gap
  });

  it('handles a large loan without floating point drift', () => {
    const r = engine.loan({ loanPrincipalOverride: 500000, annualInterestRate: 8.25, repaymentYears: 25 }, undefined as never);
    expect(r.monthlyPayment).toBeCloseTo(3942.25, 1);
  });
});

describe('CalculationEngine — career & take-home (§21, §22)', () => {
  it('computes monthly gross and take-home', () => {
    const r = engine.career({ startingSalary: 85000, takeHomeRate: 0.7 });
    expect(r.monthlyGross).toBeCloseTo(7083.33, 2);
    expect(r.monthlyTakeHome).toBeCloseTo(4958.33, 2);
  });
});

describe('CalculationEngine — debt burden (§23)', () => {
  it('classifies bands from thresholds', () => {
    expect(engine.debtBurden(D(400), D(5000)).band).toBe('low'); // 8%
    expect(engine.debtBurden(D(750), D(5000)).band).toBe('moderate'); // 15%
    expect(engine.debtBurden(D(1250), D(5000)).band).toBe('elevated'); // 25%
    expect(engine.debtBurden(D(2000), D(5000)).band).toBe('high'); // 40%
  });

  it('treats zero income with a payment as maximum burden', () => {
    const r = engine.debtBurden(D(500), D(0));
    expect(r.band).toBe('high');
    expect(r.loanPaymentBurden).toBe(100);
  });

  // local helper mirroring Decimal usage
  function D(n: number) {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    return new (require('decimal.js').Decimal)(n);
  }
});

describe('CalculationEngine — score (§24, §25)', () => {
  it('returns a 0..100 score with explainable factors summing to it', () => {
    const full = engine.full(baseInputs());
    expect(full.score.score).toBeGreaterThanOrEqual(0);
    expect(full.score.score).toBeLessThanOrEqual(100);
    const sum = full.score.factors.reduce((a, f) => a + f.contribution, 0);
    expect(sum).toBeCloseTo(full.score.score, 0);
    expect(full.score.factors).toHaveLength(5);
    full.score.factors.forEach((f) => expect(f.explanation.length).toBeGreaterThan(10));
  });

  it('a fully-funded, high-salary, no-debt plan scores strong', () => {
    const full = engine.full(
      baseInputs({
        funding: {
          scholarships: 144000, grants: 0, savings: 0, familyContribution: 0,
          assistantship: 0, employerContribution: 0, otherFunding: 0,
        },
        career: { startingSalary: 120000, takeHomeRate: 0.7 },
      }),
    );
    expect(full.loan.principal).toBe(0);
    expect(full.score.classification).toBe('strong');
  });

  it('a high-cost, unfunded, low-salary plan scores under pressure', () => {
    const full = engine.full(
      baseInputs({
        funding: {
          scholarships: 0, grants: 0, savings: 0, familyContribution: 0,
          assistantship: 0, employerContribution: 0, otherFunding: 0,
        },
        career: { startingSalary: 32000, takeHomeRate: 0.7 },
      }),
    );
    expect(full.score.score).toBeLessThan(40);
    expect(full.score.classification).toBe('pressure');
  });
});

describe('CalculationEngine — what-if (§64)', () => {
  it('re-runs the entire model and reports directional differences', () => {
    const base = baseInputs();
    const scenario = baseInputs({
      funding: { ...base.funding, scholarships: base.funding.scholarships + 10000 },
    });
    const r = engine.whatIf(base, scenario);

    const borrowing = r.differences.find((d) => d.field === 'principal')!;
    expect(borrowing.baseline).toBe(109000);
    expect(borrowing.scenario).toBe(99000); // $10k more scholarship → $10k less borrowing
    expect(borrowing.delta).toBe(-10000);
    expect(borrowing.direction).toBe('improvement');

    const payment = r.differences.find((d) => d.field === 'monthlyPayment')!;
    expect(payment.scenario).toBeLessThan(payment.baseline);
    expect(payment.direction).toBe('improvement');
  });

  it('a lower starting salary worsens burden and score', () => {
    const base = baseInputs();
    const scenario = baseInputs({ career: { startingSalary: 70000, takeHomeRate: 0.7 } });
    const r = engine.whatIf(base, scenario);
    const burden = r.differences.find((d) => d.field === 'loanPaymentBurden')!;
    expect(burden.direction).toBe('worsening');
    const score = r.differences.find((d) => d.field === 'score')!;
    expect(score.scenario).toBeLessThanOrEqual(score.baseline);
  });
});
