import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import {
  AuthUser,
  CurrentUser,
} from '../common/decorators/current-user.decorator';
import { CreateScenarioDto } from './dto/scenario.dto';
import { ScenariosService } from './scenarios.service';

@Controller('scenarios')
@UseGuards(JwtAuthGuard)
export class ScenariosController {
  constructor(private readonly service: ScenariosService) {}

  @Post()
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateScenarioDto) {
    return this.service.create(user.userId, dto);
  }

  @Get()
  findAll(@CurrentUser() user: AuthUser) {
    return this.service.findAll(user.userId);
  }

  @Get(':id')
  findOne(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.service.findOne(user.userId, id);
  }

  @Delete(':id')
  remove(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.service.remove(user.userId, id);
  }
}
