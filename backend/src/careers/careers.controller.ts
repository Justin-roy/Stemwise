import { Controller, Get, Param, Query } from '@nestjs/common';
import { CareersService } from './careers.service';

@Controller('careers')
export class CareersController {
  constructor(private readonly service: CareersService) {}

  @Get()
  findAll(@Query('field') field?: string) {
    return this.service.findAll(field);
  }

  @Get(':slug')
  findOne(@Param('slug') slug: string) {
    return this.service.findBySlug(slug);
  }
}
