/* eslint-disable no-console */
import 'reflect-metadata';
import mongoose from 'mongoose';
import { CareerSchema } from '../careers/schemas/career.schema';
import { ProgramSchema } from '../universities/schemas/program.schema';
import { UniversitySchema } from '../universities/schemas/university.schema';

/**
 * Seeds DEMO data (spec §82) — clearly labeled, never presented as authoritative
 * real-world data. Every record carries a `dataSource` / `source` = "Demo data".
 *
 * Run: npm run seed   (DATABASE_URL must point at a running MongoDB)
 */
const DATA_SOURCE = 'Demo data';
const TODAY = new Date().toISOString().slice(0, 10);

async function run() {
  const uri = process.env.DATABASE_URL ?? 'mongodb://localhost:27017/stemwise';
  await mongoose.connect(uri);
  console.log(`Connected to ${uri}`);

  const University = mongoose.model('University', UniversitySchema);
  const Program = mongoose.model('Program', ProgramSchema);
  const Career = mongoose.model('Career', CareerSchema);

  await Promise.all([
    University.deleteMany({}),
    Program.deleteMany({}),
    Career.deleteMany({}),
  ]);
  console.log('Cleared existing university/program/career data.');

  const universities = await University.insertMany([
    { name: 'Northgate State University', location: { country: 'US', state: 'California', city: 'Riverton' }, type: 'public', website: 'https://example.edu/northgate', isActive: true, dataSource: DATA_SOURCE, lastUpdated: TODAY },
    { name: 'Lakeside Institute of Technology', location: { country: 'US', state: 'Massachusetts', city: 'Harbor City' }, type: 'private', website: 'https://example.edu/lakeside', isActive: true, dataSource: DATA_SOURCE, lastUpdated: TODAY },
    { name: 'Meridian Public University', location: { country: 'US', state: 'Texas', city: 'Ashford' }, type: 'public', website: 'https://example.edu/meridian', isActive: true, dataSource: DATA_SOURCE, lastUpdated: TODAY },
    { name: 'Summit Polytechnic', location: { country: 'US', state: 'Washington', city: 'Fairview' }, type: 'private', website: 'https://example.edu/summit', isActive: true, dataSource: DATA_SOURCE, lastUpdated: TODAY },
  ]);
  console.log(`Inserted ${universities.length} demo universities.`);

  const fields = [
    { field: 'computer-science', name: 'Computer Science' },
    { field: 'data-science', name: 'Data Science' },
    { field: 'engineering', name: 'Engineering' },
    { field: 'biotechnology', name: 'Biotechnology' },
  ];

  const programs: Record<string, unknown>[] = [];
  universities.forEach((uni, i) => {
    fields.forEach((f, j) => {
      const baseTuition = uni.get('type') === 'private' ? 34000 : 16000;
      const spread = (i * 1500) + (j * 900);
      ['bachelors', 'masters'].forEach((degreeLevel) => {
        programs.push({
          universityId: uni._id,
          name: f.name,
          field: f.field,
          degreeLevel,
          durationYears: degreeLevel === 'masters' ? 2 : 4,
          tuitionAnnual: baseTuition + spread,
          feesAnnual: 1500,
          livingCostAnnual: 14000 + i * 1200,
        });
      });
    });
  });
  await Program.insertMany(programs);
  console.log(`Inserted ${programs.length} demo programs.`);

  const careers = await Career.insertMany([
    { slug: 'software-engineer', title: 'Software Engineer', description: 'Designs, builds and maintains software systems and applications.', field: 'computer-science', typicalDegreeLevel: 'bachelors', typicalProgramYears: 4, startingSalary: 85000, salaryRangeMin: 65000, salaryRangeMax: 120000, currency: 'USD', country: 'US', educationRequirements: 'Bachelor’s in CS or related field.', relatedFields: ['computer-science', 'data-science'], source: DATA_SOURCE, lastUpdated: TODAY, year: 2026 },
    { slug: 'data-scientist', title: 'Data Scientist', description: 'Analyzes complex data to inform decisions using statistics and ML.', field: 'data-science', typicalDegreeLevel: 'masters', typicalProgramYears: 2, startingSalary: 95000, salaryRangeMin: 75000, salaryRangeMax: 140000, currency: 'USD', country: 'US', educationRequirements: 'Bachelor’s or Master’s in a quantitative field.', relatedFields: ['data-science', 'computer-science', 'mathematics'], source: DATA_SOURCE, lastUpdated: TODAY, year: 2026 },
    { slug: 'mechanical-engineer', title: 'Mechanical Engineer', description: 'Designs and tests mechanical devices and systems.', field: 'engineering', typicalDegreeLevel: 'bachelors', typicalProgramYears: 4, startingSalary: 72000, salaryRangeMin: 58000, salaryRangeMax: 105000, currency: 'USD', country: 'US', educationRequirements: 'Bachelor’s in Mechanical Engineering.', relatedFields: ['engineering'], source: DATA_SOURCE, lastUpdated: TODAY, year: 2026 },
    { slug: 'electrical-engineer', title: 'Electrical Engineer', description: 'Designs electrical systems, circuits and electronics.', field: 'engineering', typicalDegreeLevel: 'bachelors', typicalProgramYears: 4, startingSalary: 76000, salaryRangeMin: 60000, salaryRangeMax: 110000, currency: 'USD', country: 'US', educationRequirements: 'Bachelor’s in Electrical Engineering.', relatedFields: ['engineering'], source: DATA_SOURCE, lastUpdated: TODAY, year: 2026 },
    { slug: 'biomedical-engineer', title: 'Biomedical Engineer', description: 'Applies engineering to medicine and biology.', field: 'biotechnology', typicalDegreeLevel: 'masters', typicalProgramYears: 2, startingSalary: 74000, salaryRangeMin: 60000, salaryRangeMax: 108000, currency: 'USD', country: 'US', educationRequirements: 'Bachelor’s or Master’s in Biomedical Engineering.', relatedFields: ['biotechnology', 'engineering'], source: DATA_SOURCE, lastUpdated: TODAY, year: 2026 },
    { slug: 'research-scientist', title: 'Research Scientist', description: 'Conducts scientific research to advance knowledge in a field.', field: 'physics', typicalDegreeLevel: 'phd', typicalProgramYears: 5, startingSalary: 80000, salaryRangeMin: 60000, salaryRangeMax: 130000, currency: 'USD', country: 'US', educationRequirements: 'Master’s or PhD in a scientific field.', relatedFields: ['physics', 'mathematics', 'biotechnology'], source: DATA_SOURCE, lastUpdated: TODAY, year: 2026 },
    { slug: 'cybersecurity-analyst', title: 'Cybersecurity Analyst', description: 'Protects systems and networks from security threats.', field: 'computer-science', typicalDegreeLevel: 'bachelors', typicalProgramYears: 4, startingSalary: 82000, salaryRangeMin: 65000, salaryRangeMax: 120000, currency: 'USD', country: 'US', educationRequirements: 'Bachelor’s in CS, IT or related field.', relatedFields: ['computer-science'], source: DATA_SOURCE, lastUpdated: TODAY, year: 2026 },
    { slug: 'civil-engineer', title: 'Civil Engineer', description: 'Designs and oversees construction of infrastructure projects.', field: 'engineering', typicalDegreeLevel: 'bachelors', typicalProgramYears: 4, startingSalary: 70000, salaryRangeMin: 55000, salaryRangeMax: 100000, currency: 'USD', country: 'US', educationRequirements: 'Bachelor’s in Civil Engineering.', relatedFields: ['engineering'], source: DATA_SOURCE, lastUpdated: TODAY, year: 2026 },
  ]);
  console.log(`Inserted ${careers.length} demo careers.`);

  await mongoose.disconnect();
  console.log('Seed complete. (All records labeled "Demo data".)');
}

run().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
