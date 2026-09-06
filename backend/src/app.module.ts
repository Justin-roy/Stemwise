import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import configuration from './config/configuration';
import { AuthModule } from './auth/auth.module';
import { CalculationsModule } from './calculations/calculations.module';
import { CareersModule } from './careers/careers.module';
import { HealthModule } from './health/health.module';
import { NotificationsModule } from './notifications/notifications.module';
import { ProfilesModule } from './profiles/profiles.module';
import { SavedPlansModule } from './saved-plans/saved-plans.module';
import { ScenariosModule } from './scenarios/scenarios.module';
import { UniversitiesModule } from './universities/universities.module';
import { UsersModule } from './users/users.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, load: [configuration] }),
    MongooseModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        uri: config.get<string>('database.uri'),
      }),
    }),
    ThrottlerModule.forRoot([{ ttl: 60_000, limit: 120 }]),
    CalculationsModule,
    AuthModule,
    UsersModule,
    ProfilesModule,
    UniversitiesModule,
    CareersModule,
    SavedPlansModule,
    ScenariosModule,
    NotificationsModule,
    HealthModule,
  ],
  providers: [{ provide: APP_GUARD, useClass: ThrottlerGuard }],
})
export class AppModule {}
