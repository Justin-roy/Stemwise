import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { User, UserDocument } from './schemas/user.schema';

@Injectable()
export class UsersService {
  constructor(@InjectModel(User.name) private readonly userModel: Model<UserDocument>) {}

  create(email: string, passwordHash: string, role: 'user' | 'admin' = 'user') {
    return this.userModel.create({ email: email.toLowerCase(), passwordHash, role });
  }

  findById(id: string | Types.ObjectId) {
    return this.userModel.findById(id).exec();
  }

  /** Includes passwordHash for auth verification only. */
  findByEmailWithSecret(email: string) {
    return this.userModel
      .findOne({ email: email.toLowerCase() })
      .select('+passwordHash')
      .exec();
  }

  findByIdWithRefresh(id: string) {
    return this.userModel.findById(id).select('+refreshTokenHash').exec();
  }

  setRefreshTokenHash(id: string, hash: string | null) {
    return this.userModel.findByIdAndUpdate(id, { refreshTokenHash: hash }).exec();
  }

  deleteById(id: string) {
    return this.userModel.findByIdAndDelete(id).exec();
  }
}
