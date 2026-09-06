import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';

export type ScenarioDocument = HydratedDocument<Scenario>;

@Schema({ timestamps: true })
export class Scenario {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true, index: true })
  userId!: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'SavedPlan' }) planId?: Types.ObjectId;
  @Prop({ required: true }) name!: string;

  @Prop({ type: Object, required: true }) baselineInputs!: Record<string, unknown>;
  @Prop({ type: Object, required: true }) scenarioInputs!: Record<string, unknown>;
}

export const ScenarioSchema = SchemaFactory.createForClass(Scenario);
