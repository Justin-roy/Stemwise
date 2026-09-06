import { Body, Controller, Get, Patch, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import {
  AuthUser,
  CurrentUser,
} from '../common/decorators/current-user.decorator';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { ProfilesService } from './profiles.service';

@Controller('profile')
@UseGuards(JwtAuthGuard)
export class ProfilesController {
  constructor(private readonly service: ProfilesService) {}

  @Get()
  get(@CurrentUser() user: AuthUser) {
    return this.service.findByUserId(user.userId);
  }

  @Patch()
  update(@CurrentUser() user: AuthUser, @Body() dto: UpdateProfileDto) {
    return this.service.update(user.userId, dto);
  }
}
