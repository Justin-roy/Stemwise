import { Type } from 'class-transformer';
import {
  IsMongoId,
  IsOptional,
  IsString,
  MaxLength,
  ValidateNested,
} from 'class-validator';
import { CalculationInputDto } from '../../calculations/dto/calculation-input.dto';

export class CreateScenarioDto {
  @IsString() @MaxLength(120) name!: string;
  @IsOptional() @IsMongoId() planId?: string;
  @ValidateNested() @Type(() => CalculationInputDto) baselineInputs!: CalculationInputDto;
  @ValidateNested() @Type(() => CalculationInputDto) scenarioInputs!: CalculationInputDto;
}
