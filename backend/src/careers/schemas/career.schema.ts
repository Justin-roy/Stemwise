import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type CareerDocument = HydratedDocument<Career>;

/**
 * Salary is always an ESTIMATE — never a guarantee of employment or income
 * (spec §21, §53, §98). Every record carries a source + lastUpdated.
 */
@Schema({ timestamps: true })
export class Career {
  @Prop({ required: true, unique: true, index: true }) slug!: string;
  @Prop({ required: true }) title!: string;
  @Prop({ required: true }) description!: string;
  @Prop({ required: true, index: true }) field!: string;
  @Prop({ enum: ['bachelors', 'masters', 'phd'] }) typicalDegreeLevel?: string;
  @Prop() typicalProgramYears?: number;

  @Prop({ required: true, min: 0 }) startingSalary!: number;
  @Prop({ min: 0 }) salaryRangeMin?: number;
  @Prop({ min: 0 }) salaryRangeMax?: number;
  @Prop({ default: 'USD' }) currency!: string;
  @Prop({ default: 'US' }) country!: string;

  @Prop() educationRequirements?: string;
  @Prop({ type: [String], default: [] }) relatedFields!: string[];
  @Prop() source?: string;
  @Prop() lastUpdated?: string;
  @Prop() year?: number;
}

export const CareerSchema = SchemaFactory.createForClass(Career);
