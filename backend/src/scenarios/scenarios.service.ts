import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { CalculationsService } from '../calculations/calculations.service';
import { CalculationInputs } from '../calculations/engine/calculation.types';
import { CreateScenarioDto } from './dto/scenario.dto';
import { Scenario, ScenarioDocument } from './schemas/scenario.schema';

@Injectable()
export class ScenariosService {
  constructor(
    @InjectModel(Scenario.name) private readonly model: Model<ScenarioDocument>,
    private readonly calculations: CalculationsService,
  ) {}

  private oid(id: string) {
    return new Types.ObjectId(id);
  }

  private safeId(id: string) {
    if (!Types.ObjectId.isValid(id)) throw new NotFoundException('Scenario not found.');
    return new Types.ObjectId(id);
  }

  async create(userId: string, dto: CreateScenarioDto) {
    const doc = await this.model.create({
      userId: this.oid(userId),
      planId: dto.planId ? this.oid(dto.planId) : undefined,
      name: dto.name,
      baselineInputs: dto.baselineInputs,
      scenarioInputs: dto.scenarioInputs,
    });
    return this.withComparison(doc.toObject() as unknown as Record<string, unknown>);
  }

  async findAll(userId: string) {
    const docs = await this.model
      .find({ userId: this.oid(userId) })
      .sort({ createdAt: -1 })
      .lean()
      .exec();
    return docs.map((d) => this.withComparison(d));
  }

  async findOne(userId: string, id: string) {
    const doc = await this.model
      .findOne({ _id: this.safeId(id), userId: this.oid(userId) })
      .lean()
      .exec();
    if (!doc) throw new NotFoundException('Scenario not found.');
    return this.withComparison(doc);
  }

  async remove(userId: string, id: string) {
    const res = await this.model
      .deleteOne({ _id: this.safeId(id), userId: this.oid(userId) })
      .exec();
    if (res.deletedCount === 0) throw new NotFoundException('Scenario not found.');
    return { deleted: true };
  }

  private withComparison(doc: Record<string, unknown>) {
    const comparison = this.calculations.whatIf(
      doc.baselineInputs as unknown as CalculationInputs,
      doc.scenarioInputs as unknown as CalculationInputs,
    );
    return { ...doc, comparison };
  }
}
