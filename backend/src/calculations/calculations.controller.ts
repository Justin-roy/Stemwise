import { Body, Controller, Get, HttpCode, HttpStatus, Post } from '@nestjs/common';
import { CalculationsService } from './calculations.service';
import { CalculationInputDto, WhatIfInputDto } from './dto/calculation-input.dto';

/**
 * Public calculation endpoints (spec §59). Anonymous users can use the entire
 * calculator without an account (spec §76). All results derive from inputs.
 */
@Controller('calculations')
export class CalculationsController {
  constructor(private readonly service: CalculationsService) {}

  @Post('cost')
  @HttpCode(HttpStatus.OK)
  cost(@Body() dto: CalculationInputDto) {
    return this.service.cost(dto.costs);
  }

  @Post('funding')
  @HttpCode(HttpStatus.OK)
  funding(@Body() dto: CalculationInputDto) {
    return this.service.funding(dto);
  }

  @Post('loan')
  @HttpCode(HttpStatus.OK)
  loan(@Body() dto: CalculationInputDto) {
    return this.service.loan(dto);
  }

  @Post('career')
  @HttpCode(HttpStatus.OK)
  career(@Body() dto: CalculationInputDto) {
    return this.service.career(dto.career);
  }

  @Post('score')
  @HttpCode(HttpStatus.OK)
  score(@Body() dto: CalculationInputDto) {
    return this.service.full(dto).score;
  }

  @Post('full')
  @HttpCode(HttpStatus.OK)
  full(@Body() dto: CalculationInputDto) {
    return this.service.full(dto);
  }

  @Post('what-if')
  @HttpCode(HttpStatus.OK)
  whatIf(@Body() dto: WhatIfInputDto) {
    return this.service.whatIf(dto.baseline, dto.scenario);
  }

  @Get('assumptions')
  assumptions() {
    return this.service.assumptions();
  }
}
