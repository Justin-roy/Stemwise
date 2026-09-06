import { Decimal } from 'decimal.js';

/**
 * Decimal-safe money helpers.
 *
 * Financial calculations must NOT rely on JS floating point (spec §19, §62, §90).
 * All internal math runs through Decimal.js; we round ONLY for display/output.
 *
 * Configure Decimal for high precision to keep amortization exponentials accurate.
 */
Decimal.set({ precision: 40, rounding: Decimal.ROUND_HALF_UP });

export type Numeric = number | string | Decimal;

export const D = (v: Numeric = 0): Decimal => new Decimal(v ?? 0);

/** Sum a list of numerics with full precision. */
export const dSum = (values: Numeric[]): Decimal =>
  values.reduce<Decimal>((acc, v) => acc.plus(D(v)), D(0));

/** max(0, value) — used for funding gap / interest which must never be negative. */
export const dClampMin0 = (value: Decimal): Decimal =>
  value.isNegative() ? D(0) : value;

/** Round a Decimal to `dp` decimal places and return a plain JS number for JSON output. */
export const toNumber = (value: Decimal, dp = 2): number =>
  value.toDecimalPlaces(dp, Decimal.ROUND_HALF_UP).toNumber();

/** Round to 2dp currency and return a number (display precision). */
export const money = (value: Decimal): number => toNumber(value, 2);

/** Round to `dp` and return a number (default 1dp for percentages/ratios). */
export const pct = (value: Decimal, dp = 1): number => toNumber(value, dp);

export { Decimal };
