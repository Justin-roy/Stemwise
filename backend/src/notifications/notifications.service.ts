import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Notification, NotificationDocument } from './schemas/notification.schema';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectModel(Notification.name)
    private readonly model: Model<NotificationDocument>,
  ) {}

  private oid(id: string) {
    return new Types.ObjectId(id);
  }

  create(userId: string, title: string, message: string, type = 'general') {
    return this.model.create({ userId: this.oid(userId), title, message, type });
  }

  findAll(userId: string) {
    return this.model
      .find({ userId: this.oid(userId) })
      .sort({ createdAt: -1 })
      .lean()
      .exec();
  }

  async markRead(userId: string, id: string) {
    if (!Types.ObjectId.isValid(id)) throw new NotFoundException('Notification not found.');
    const res = await this.model
      .findOneAndUpdate(
        { _id: this.oid(id), userId: this.oid(userId) },
        { read: true },
        { new: true },
      )
      .lean()
      .exec();
    if (!res) throw new NotFoundException('Notification not found.');
    return res;
  }

  async markAllRead(userId: string) {
    await this.model.updateMany({ userId: this.oid(userId), read: false }, { read: true }).exec();
    return { updated: true };
  }
}
