import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { CalculationsModule } from '../calculations/calculations.module';
import { ScenariosController } from './scenarios.controller';
import { ScenariosService } from './scenarios.service';
import { Scenario, ScenarioSchema } from './schemas/scenario.schema';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Scenario.name, schema: ScenarioSchema }]),
    CalculationsModule,
  ],
  controllers: [ScenariosController],
  providers: [ScenariosService],
})
export class ScenariosModule {}
