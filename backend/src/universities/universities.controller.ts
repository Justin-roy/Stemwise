import { Controller, Get, Param, Query } from '@nestjs/common';
import { QueryUniversitiesDto } from './dto/query-universities.dto';
import { UniversitiesService } from './universities.service';

@Controller('universities')
export class UniversitiesController {
  constructor(private readonly service: UniversitiesService) {}

  @Get()
  search(@Query() query: QueryUniversitiesDto) {
    return this.service.search(query);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.service.findById(id);
  }

  @Get(':id/programs')
  programs(@Param('id') id: string) {
    return this.service.findProgramsByUniversity(id);
  }
}
