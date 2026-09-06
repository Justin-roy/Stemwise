import { Type } from 'class-transformer';
import {
  IsMongoId,
  IsOptional,
  IsString,
  MaxLength,
  ValidateNested,
} from 'class-validator';
import { CalculationInputDto } from '../../calculations/dto/calculation-input.dto';

export class CreateSavedPlanDto {
  @IsString() @MaxLength(120) name!: string;
  @IsOptional() @IsString() degreeLevel?: string;
  @IsOptional() @IsString() field?: string;
  @IsOptional() @IsMongoId() universityId?: string;
  @ValidateNested() @Type(() => CalculationInputDto) inputs!: CalculationInputDto;
}

export class UpdateSavedPlanDto {
  @IsOptional() @IsString() @MaxLength(120) name?: string;
  @IsOptional() @IsString() degreeLevel?: string;
  @IsOptional() @IsString() field?: string;
  @IsOptional() @IsMongoId() universityId?: string;
  @IsOptional() @ValidateNested() @Type(() => CalculationInputDto) inputs?: CalculationInputDto;
}
