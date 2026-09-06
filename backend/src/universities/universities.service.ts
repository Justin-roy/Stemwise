import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { FilterQuery, Model, Types } from 'mongoose';
import { QueryUniversitiesDto } from './dto/query-universities.dto';
import { Program, ProgramDocument } from './schemas/program.schema';
import { University, UniversityDocument } from './schemas/university.schema';

@Injectable()
export class UniversitiesService {
  constructor(
    @InjectModel(University.name) private readonly uniModel: Model<UniversityDocument>,
    @InjectModel(Program.name) private readonly programModel: Model<ProgramDocument>,
  ) {}

  async search(query: QueryUniversitiesDto) {
    const uniFilter: FilterQuery<UniversityDocument> = { isActive: true };
    if (query.search) uniFilter.name = { $regex: query.search, $options: 'i' };
    if (query.country) uniFilter['location.country'] = query.country;
    if (query.state) uniFilter['location.state'] = query.state;
    if (query.type) uniFilter.type = query.type;

    // Program-level filters constrain which universities qualify.
    const usesProgramFilter =
      query.field ||
      query.degreeLevel ||
      query.tuitionMin != null ||
      query.tuitionMax != null;

    if (usesProgramFilter) {
      const programFilter: FilterQuery<ProgramDocument> = {};
      if (query.field) programFilter.field = query.field;
      if (query.degreeLevel) programFilter.degreeLevel = query.degreeLevel;
      if (query.tuitionMin != null || query.tuitionMax != null) {
        programFilter.tuitionAnnual = {};
        if (query.tuitionMin != null) programFilter.tuitionAnnual.$gte = query.tuitionMin;
        if (query.tuitionMax != null) programFilter.tuitionAnnual.$lte = query.tuitionMax;
      }
      const uniIds = await this.programModel.distinct('universityId', programFilter);
      uniFilter._id = { $in: uniIds };
    }

    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;

    const [data, total] = await Promise.all([
      this.uniModel.find(uniFilter).sort({ name: 1 }).skip(skip).limit(limit).lean().exec(),
      this.uniModel.countDocuments(uniFilter).exec(),
    ]);

    return { data, meta: { page, limit, total } };
  }

  async findById(id: string) {
    if (!Types.ObjectId.isValid(id)) throw new NotFoundException('University not found.');
    const uni = await this.uniModel.findById(id).lean().exec();
    if (!uni) throw new NotFoundException('University not found.');
    return uni;
  }

  async findProgramsByUniversity(id: string) {
    if (!Types.ObjectId.isValid(id)) throw new NotFoundException('University not found.');
    return this.programModel.find({ universityId: new Types.ObjectId(id) }).lean().exec();
  }
}
