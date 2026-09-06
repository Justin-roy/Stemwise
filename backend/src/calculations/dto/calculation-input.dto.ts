import { Type } from 'class-transformer';
import {
  IsInt,
  IsNumber,
  IsOptional,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';

/**
 * Input DTOs for the calculation engine (spec §61, §63, §68).
 * Rejects negatives, NaN, Infinity (isNumber blocks NaN/Infinity), and out-of-range values.
 */

const money = { maxDecimalPlaces: 2 } as const;

export class CostInputDto {
  @IsNumber(money) @Min(0) @Max(10_000_000) tuitionAnnual!: number;
  @IsNumber(money) @Min(0) @Max(10_000_000) housingAnnual!: number;
  @IsNumber(money) @Min(0) @Max(10_000_000) foodAnnual!: number;
  @IsNumber(money) @Min(0) @Max(10_000_000) booksAnnual!: number;
  @IsNumber(money) @Min(0) @Max(10_000_000) transportationAnnual!: number;
  @IsNumber(money) @Min(0) @Max(10_000_000) otherAnnual!: number;
  @IsInt() @Min(1) @Max(10) programYears!: number;
}

export class FundingInputDto {
  @IsNumber(money) @Min(0) @Max(10_000_000) scholarships!: number;
  @IsNumber(money) @Min(0) @Max(10_000_000) grants!: number;
  @IsNumber(money) @Min(0) @Max(10_000_000) savings!: number;
  @IsNumber(money) @Min(0) @Max(10_000_000) familyContribution!: number;
  @IsNumber(money) @Min(0) @Max(10_000_000) assistantship!: number;
  @IsNumber(money) @Min(0) @Max(10_000_000) employerContribution!: number;
  @IsNumber(money) @Min(0) @Max(10_000_000) otherFunding!: number;
}

export class LoanInputDto {
  @IsOptional()
  @IsNumber(money)
  @Min(0)
  @Max(10_000_000)
  loanPrincipalOverride?: number | null;

  @IsNumber({ maxDecimalPlaces: 4 }) @Min(0) @Max(30) annualInterestRate!: number;
  @IsInt() @Min(1) @Max(40) repaymentYears!: number;
}

export class CareerInputDto {
  @IsNumber(money) @Min(0) @Max(10_000_000) startingSalary!: number;
  @IsNumber({ maxDecimalPlaces: 4 }) @Min(0) @Max(1) takeHomeRate!: number;
}

export class CalculationInputDto {
  @ValidateNested() @Type(() => CostInputDto) costs!: CostInputDto;
  @ValidateNested() @Type(() => FundingInputDto) funding!: FundingInputDto;
  @ValidateNested() @Type(() => LoanInputDto) loan!: LoanInputDto;
  @ValidateNested() @Type(() => CareerInputDto) career!: CareerInputDto;
}

export class WhatIfInputDto {
  @ValidateNested() @Type(() => CalculationInputDto) baseline!: CalculationInputDto;
  @ValidateNested() @Type(() => CalculationInputDto) scenario!: CalculationInputDto;
}
