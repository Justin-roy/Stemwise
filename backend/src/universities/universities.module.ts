import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Program, ProgramSchema } from './schemas/program.schema';
import { University, UniversitySchema } from './schemas/university.schema';
import { UniversitiesController } from './universities.controller';
import { UniversitiesService } from './universities.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: University.name, schema: UniversitySchema },
      { name: Program.name, schema: ProgramSchema },
    ]),
  ],
  controllers: [UniversitiesController],
  providers: [UniversitiesService],
  exports: [UniversitiesService],
})
export class UniversitiesModule {}
