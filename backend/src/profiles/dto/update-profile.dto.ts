import { IsIn, IsOptional, IsString, MaxLength } from 'class-validator';

export class UpdateProfileDto {
  @IsOptional() @IsString() @MaxLength(120) name?: string;
  @IsOptional() @IsString() @MaxLength(2) country?: string;
  @IsOptional() @IsString() @MaxLength(3) currency?: string;
  @IsOptional() @IsString() @MaxLength(60) preferredField?: string;
  @IsOptional() @IsIn(['bachelors', 'masters', 'phd']) degreeLevel?: string;
}
