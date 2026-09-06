import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Profile, ProfileDocument } from './schemas/profile.schema';

@Injectable()
export class ProfilesService {
  constructor(
    @InjectModel(Profile.name) private readonly model: Model<ProfileDocument>,
  ) {}

  create(userId: string, data: Partial<Profile>) {
    return this.model.create({ ...data, userId: new Types.ObjectId(userId) });
  }

  async findByUserId(userId: string) {
    const profile = await this.model
      .findOne({ userId: new Types.ObjectId(userId) })
      .exec();
    if (!profile) throw new NotFoundException('Profile not found.');
    return profile;
  }

  async update(userId: string, data: Partial<Profile>) {
    const profile = await this.model
      .findOneAndUpdate({ userId: new Types.ObjectId(userId) }, data, {
        new: true,
        upsert: true,
      })
      .exec();
    return profile;
  }

  async deleteByUserId(userId: string): Promise<void> {
    await this.model.deleteOne({ userId: new Types.ObjectId(userId) }).exec();
  }
}
