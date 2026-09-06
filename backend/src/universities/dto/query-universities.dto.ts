import { Type } from 'class-transformer';
import { IsIn, IsNumber, IsOptional, IsString, Min } from 'class-validator';
import { PaginationQueryDto } from '../../common/dto/pagination.dto';

export class QueryUniversitiesDto extends PaginationQueryDto {
  @IsOptional() @IsString() field?: string;
  @IsOptional() @IsIn(['bachelors', 'masters', 'phd']) degreeLevel?: string;
  @IsOptional() @IsString() country?: string;
  @IsOptional() @IsString() state?: string;
  @IsOptional() @IsIn(['public', 'private']) type?: string;
  @IsOptional() @Type(() => Number) @IsNumber() @Min(0) tuitionMin?: number;
  @IsOptional() @Type(() => Number) @IsNumber() @Min(0) tuitionMax?: number;
}
