import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import {
  AuthUser,
  CurrentUser,
} from '../common/decorators/current-user.decorator';
import { CreateSavedPlanDto, UpdateSavedPlanDto } from './dto/saved-plan.dto';
import { SavedPlansService } from './saved-plans.service';

@Controller('saved-plans')
@UseGuards(JwtAuthGuard)
export class SavedPlansController {
  constructor(private readonly service: SavedPlansService) {}

  @Post()
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateSavedPlanDto) {
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

  @Patch(':id')
  update(
    @CurrentUser() user: AuthUser,
    @Param('id') id: string,
    @Body() dto: UpdateSavedPlanDto,
  ) {
    return this.service.update(user.userId, id, dto);
  }

  @Delete(':id')
  remove(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.service.remove(user.userId, id);
  }
}
