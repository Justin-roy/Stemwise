import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type UniversityDocument = HydratedDocument<University>;

@Schema({ _id: false })
export class Location {
  @Prop({ index: true }) country!: string;
  @Prop({ index: true }) state?: string;
  @Prop() city?: string;
}

@Schema({ timestamps: true })
export class University {
  @Prop({ required: true, index: true }) name!: string;
  @Prop({ type: Location, required: true }) location!: Location;
  @Prop({ enum: ['public', 'private'], default: 'public' }) type!: string;
  @Prop() website?: string;
  @Prop({ default: true }) isActive!: boolean;
  @Prop() dataSource?: string; // spec §57, §109 — never invented
  @Prop() lastUpdated?: string;
}

export const UniversitySchema = SchemaFactory.createForClass(University);
UniversitySchema.index({ name: 'text' });
