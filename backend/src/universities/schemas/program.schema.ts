import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';

export type ProgramDocument = HydratedDocument<Program>;

@Schema({ timestamps: true })
export class Program {
  @Prop({ type: Types.ObjectId, ref: 'University', required: true, index: true })
  universityId!: Types.ObjectId;

  @Prop({ required: true }) name!: string;
  @Prop({ required: true, index: true }) field!: string;
  @Prop({ required: true, enum: ['bachelors', 'masters', 'phd'], index: true })
  degreeLevel!: string;

  @Prop({ required: true, min: 1, max: 10 }) durationYears!: number;
  @Prop({ required: true, min: 0 }) tuitionAnnual!: number;
  @Prop({ default: 0, min: 0 }) feesAnnual!: number;
  @Prop({ default: 0, min: 0 }) livingCostAnnual!: number;
}

export const ProgramSchema = SchemaFactory.createForClass(Program);
ProgramSchema.index({ universityId: 1, field: 1, degreeLevel: 1 });
