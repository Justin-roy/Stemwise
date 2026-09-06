import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { CalculationsModule } from '../calculations/calculations.module';
import { SavedPlansController } from './saved-plans.controller';
import { SavedPlansService } from './saved-plans.service';
import { SavedPlan, SavedPlanSchema } from './schemas/saved-plan.schema';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: SavedPlan.name, schema: SavedPlanSchema }]),
    CalculationsModule,
  ],
  controllers: [SavedPlansController],
  providers: [SavedPlansService],
})
export class SavedPlansModule {}
