import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { CalculationsService } from '../calculations/calculations.service';
import { CalculationInputs } from '../calculations/engine/calculation.types';
import { CreateSavedPlanDto, UpdateSavedPlanDto } from './dto/saved-plan.dto';
import { SavedPlan, SavedPlanDocument } from './schemas/saved-plan.schema';

@Injectable()
export class SavedPlansService {
  constructor(
    @InjectModel(SavedPlan.name) private readonly model: Model<SavedPlanDocument>,
    private readonly calculations: CalculationsService,
  ) {}

  private oid(userId: string) {
    return new Types.ObjectId(userId);
  }

  /** Every query is scoped by userId so a user can never reach another's data (RULE 13). */
  async create(userId: string, dto: CreateSavedPlanDto) {
    const plan = await this.model.create({
      userId: this.oid(userId),
      name: dto.name,
      degreeLevel: dto.degreeLevel,
      field: dto.field,
      universityId: dto.universityId ? new Types.ObjectId(dto.universityId) : undefined,
      inputs: dto.inputs,
    });
    return this.withResults(plan.toObject() as unknown as Record<string, unknown>);
  }

  async findAll(userId: string) {
    const plans = await this.model
      .find({ userId: this.oid(userId) })
      .sort({ updatedAt: -1 })
      .lean()
      .exec();
    return plans.map((p) => this.withResults(p));
  }

  async findOne(userId: string, id: string) {
    const plan = await this.requireOwned(userId, id);
    return this.withResults(plan);
  }

  async update(userId: string, id: string, dto: UpdateSavedPlanDto) {
    await this.requireOwned(userId, id);
    const update: Record<string, unknown> = { ...dto };
    if (dto.universityId) update.universityId = new Types.ObjectId(dto.universityId);
    const plan = await this.model
      .findOneAndUpdate({ _id: id, userId: this.oid(userId) }, update, { new: true })
      .lean()
      .exec();
    return this.withResults(plan!);
  }

  async remove(userId: string, id: string) {
    const res = await this.model
      .deleteOne({ _id: this.safeId(id), userId: this.oid(userId) })
      .exec();
    if (res.deletedCount === 0) throw new NotFoundException('Plan not found.');
    return { deleted: true };
  }

  private safeId(id: string) {
    if (!Types.ObjectId.isValid(id)) throw new NotFoundException('Plan not found.');
    return new Types.ObjectId(id);
  }

  private async requireOwned(userId: string, id: string) {
    const plan = await this.model
      .findOne({ _id: this.safeId(id), userId: this.oid(userId) })
      .lean()
      .exec();
    if (!plan) throw new NotFoundException('Plan not found.');
    return plan;
  }

  /** Results are always recomputed from the stored inputs (spec §54). */
  private withResults(plan: Record<string, unknown>) {
    const results = this.calculations.full(plan.inputs as unknown as CalculationInputs);
    return { ...plan, results };
  }
}
