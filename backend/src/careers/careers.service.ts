import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { FilterQuery, Model } from 'mongoose';
import { Career, CareerDocument } from './schemas/career.schema';

@Injectable()
export class CareersService {
  constructor(
    @InjectModel(Career.name) private readonly model: Model<CareerDocument>,
  ) {}

  findAll(field?: string) {
    const filter: FilterQuery<CareerDocument> = {};
    if (field) filter.field = field;
    return this.model.find(filter).sort({ title: 1 }).lean().exec();
  }

  async findBySlug(slug: string) {
    const career = await this.model.findOne({ slug }).lean().exec();
    if (!career) throw new NotFoundException('Career not found.');
    return career;
  }
}
