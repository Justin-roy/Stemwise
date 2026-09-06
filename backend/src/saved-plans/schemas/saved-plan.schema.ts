import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';

export type SavedPlanDocument = HydratedDocument<SavedPlan>;

/**
 * Inputs are the authoritative source of truth (spec §54). Results are
 * recomputable and never stored as the only truth.
 */
@Schema({ timestamps: true })
export class SavedPlan {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true, index: true })
  userId!: Types.ObjectId;

  @Prop({ required: true }) name!: string;
  @Prop() degreeLevel?: string;
  @Prop() field?: string;
  @Prop({ type: Types.ObjectId, ref: 'University' }) universityId?: Types.ObjectId;

  @Prop({ type: Object, required: true }) inputs!: Record<string, unknown>;
}

export const SavedPlanSchema = SchemaFactory.createForClass(SavedPlan);
