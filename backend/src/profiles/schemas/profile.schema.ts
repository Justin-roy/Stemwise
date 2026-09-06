import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';

export type ProfileDocument = HydratedDocument<Profile>;

@Schema({ timestamps: true })
export class Profile {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true, unique: true, index: true })
  userId!: Types.ObjectId;

  @Prop({ trim: true }) name?: string;
  @Prop({ default: 'US' }) country?: string;
  @Prop({ default: 'USD' }) currency?: string;
  @Prop() preferredField?: string;
  @Prop({ enum: ['bachelors', 'masters', 'phd'] }) degreeLevel?: string;
}

export const ProfileSchema = SchemaFactory.createForClass(Profile);
