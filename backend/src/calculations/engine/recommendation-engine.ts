import { CalculationInputs, FullCalculationResult } from './calculation.types';

export interface Recommendation {
  key: string;
  title: string;
  description: string;
  affectedVariable: string;
  estimatedImpact: string;
  /** Higher = surfaced first (spec §106). */
  priority: number;
}

/**
 * Generates ranked, explainable recommendations from actual inputs (spec §65, §106).
 * Never makes guaranteed claims; always uses "could / may / approximately".
 */
export class RecommendationEngine {
  generate(
    inputs: CalculationInputs,
    result: FullCalculationResult,
  ): Recommendation[] {
    const recs: Recommendation[] = [];
    const fmt = (n: number) =>
      `$${Math.round(n).toLocaleString('en-US')}`;

    const gap = result.funding.fundingGap;
    const burden = result.debtBurden.loanPaymentBurden;
    const livingAnnual =
      inputs.costs.housingAnnual +
      inputs.costs.foodAnnual +
      inputs.costs.transportationAnnual +
      inputs.costs.otherAnnual;

    if (gap > 0) {
      const step = Math.min(5000, gap);
      recs.push({
        key: 'more-funding',
        title: 'Find additional scholarships or grants',
        description:
          'Additional non-loan funding directly reduces the amount you may need to borrow.',
        affectedVariable: 'fundingGap',
        estimatedImpact: `If an additional ${fmt(step)} of funding becomes available, projected borrowing could decrease by approximately ${fmt(step)}.`,
        priority: 90 + Math.min(9, Math.round(gap / 20000)),
      });
    }

    if (burden >= 20 && result.loan.principal > 0) {
      recs.push({
        key: 'lower-borrowing',
        title: 'Reduce projected borrowing',
        description:
          'Your projected loan payment represents a relatively high share of estimated take-home income under the assumptions you entered.',
        affectedVariable: 'loanPaymentBurden',
        estimatedImpact: `Lowering total borrowing or choosing a lower-cost program could reduce the estimated ${burden}% payment burden.`,
        priority: 85,
      });
    }

    if (livingAnnual > inputs.costs.tuitionAnnual && livingAnnual > 0) {
      recs.push({
        key: 'lower-living',
        title: 'Consider lower living costs',
        description:
          'Living costs make up a large share of your annual cost. Reducing them lowers total cost and projected borrowing.',
        affectedVariable: 'livingCostAnnual',
        estimatedImpact: `Reducing living costs by ${fmt(2000)}/year could lower total cost by approximately ${fmt(2000 * inputs.costs.programYears)} over the program.`,
        priority: 70,
      });
    }

    if (result.cost.totalEducationCost > 0) {
      recs.push({
        key: 'compare-universities',
        title: 'Compare lower-cost universities',
        description:
          'Programs vary widely in total estimated cost. Comparing options may reveal a similar path with lower projected debt.',
        affectedVariable: 'totalEducationCost',
        estimatedImpact:
          'Comparing programs with lower total estimated costs may reduce projected borrowing.',
        priority: 60,
      });
    }

    if (inputs.costs.programYears > 2) {
      recs.push({
        key: 'shorter-program',
        title: 'Explore shorter or accelerated programs',
        description:
          'A shorter program reduces the number of years of tuition and living costs.',
        affectedVariable: 'programYears',
        estimatedImpact: `Each year removed could lower total cost by approximately ${fmt(result.cost.annualCost)}.`,
        priority: 50,
      });
    }

    return recs.sort((a, b) => b.priority - a.priority);
  }
}
