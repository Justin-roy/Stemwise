import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { MongoMemoryServer } from 'mongodb-memory-server';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { AllExceptionsFilter } from '../src/common/filters/http-exception.filter';
import { ResponseInterceptor } from '../src/common/interceptors/response.interceptor';

describe('STEMWISE API (e2e)', () => {
  let app: INestApplication;
  let mongo: MongoMemoryServer;

  const fullInputs = {
    costs: {
      tuitionAnnual: 20000, housingAnnual: 8000, foodAnnual: 4000,
      booksAnnual: 1200, transportationAnnual: 1000, otherAnnual: 1800,
      programYears: 4,
    },
    funding: {
      scholarships: 15000, grants: 5000, savings: 10000, familyContribution: 5000,
      assistantship: 0, employerContribution: 0, otherFunding: 0,
    },
    loan: { loanPrincipalOverride: null, annualInterestRate: 6.5, repaymentYears: 10 },
    career: { startingSalary: 85000, takeHomeRate: 0.7 },
  };

  beforeAll(async () => {
    mongo = await MongoMemoryServer.create();
    process.env.DATABASE_URL = mongo.getUri();
    process.env.JWT_ACCESS_SECRET = 'test-access';
    process.env.JWT_REFRESH_SECRET = 'test-refresh';

    const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = moduleRef.createNestApplication();
    app.setGlobalPrefix('api/v1');
    app.useGlobalPipes(
      new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }),
    );
    app.useGlobalInterceptors(new ResponseInterceptor());
    app.useGlobalFilters(new AllExceptionsFilter());
    await app.init();
  });

  afterAll(async () => {
    await app?.close();
    await mongo?.stop();
  });

  const api = () => request(app.getHttpServer());

  it('GET /health reports ok + connected db', async () => {
    const res = await api().get('/api/v1/health').expect(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.status).toBe('ok');
    expect(res.body.data.database).toBe('connected');
  });

  it('POST /calculations/full computes §89 numbers and wraps in envelope', async () => {
    const res = await api().post('/api/v1/calculations/full').send(fullInputs).expect(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.cost.totalEducationCost).toBe(144000);
    expect(res.body.data.funding.fundingGap).toBe(109000);
    expect(res.body.data.loan.principal).toBe(109000);
    expect(res.body.data.score.score).toBeGreaterThanOrEqual(0);
    expect(res.body.data.score.score).toBeLessThanOrEqual(100);
    expect(Array.isArray(res.body.data.recommendations)).toBe(true);
  });

  it('POST /calculations/what-if recalculates and reports differences', async () => {
    const scenario = {
      ...fullInputs,
      funding: { ...fullInputs.funding, scholarships: 25000 },
    };
    const res = await api()
      .post('/api/v1/calculations/what-if')
      .send({ baseline: fullInputs, scenario })
      .expect(200);
    const borrowing = res.body.data.differences.find((d: any) => d.field === 'principal');
    expect(borrowing.baseline).toBe(109000);
    expect(borrowing.scenario).toBe(99000);
    expect(borrowing.direction).toBe('improvement');
  });

  it('rejects negative financial input with a validation error', async () => {
    const bad = { ...fullInputs, costs: { ...fullInputs.costs, tuitionAnnual: -5 } };
    const res = await api().post('/api/v1/calculations/full').send(bad).expect(400);
    expect(res.body.success).toBe(false);
    expect(res.body.code).toBe('VALIDATION_ERROR');
  });

  describe('auth + saved plans + ownership (RULE 13)', () => {
    let tokenA = '';
    let tokenB = '';
    let planAId = '';

    it('registers and logs in user A', async () => {
      const reg = await api()
        .post('/api/v1/auth/register')
        .send({ email: 'a@example.com', password: 'password123', name: 'User A' })
        .expect(201);
      expect(reg.body.data.accessToken).toBeTruthy();

      const login = await api()
        .post('/api/v1/auth/login')
        .send({ email: 'a@example.com', password: 'password123' })
        .expect(200);
      tokenA = login.body.data.accessToken;
      expect(tokenA).toBeTruthy();
    });

    it('rejects a duplicate email', async () => {
      await api()
        .post('/api/v1/auth/register')
        .send({ email: 'a@example.com', password: 'password123' })
        .expect(409);
    });

    it('registers user B', async () => {
      const reg = await api()
        .post('/api/v1/auth/register')
        .send({ email: 'b@example.com', password: 'password123' })
        .expect(201);
      tokenB = reg.body.data.accessToken;
    });

    it('blocks saved-plan access without a token', async () => {
      await api().get('/api/v1/saved-plans').expect(401);
    });

    it('user A creates a plan; results are recomputed from inputs', async () => {
      const res = await api()
        .post('/api/v1/saved-plans')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ name: 'MS CS Plan', field: 'computer-science', degreeLevel: 'masters', inputs: fullInputs })
        .expect(201);
      planAId = res.body.data._id;
      expect(res.body.data.results.funding.fundingGap).toBe(109000);
    });

    it('user A sees their plan in the list', async () => {
      const res = await api()
        .get('/api/v1/saved-plans')
        .set('Authorization', `Bearer ${tokenA}`)
        .expect(200);
      expect(res.body.data).toHaveLength(1);
    });

    it('user B CANNOT read user A\'s plan (no IDOR)', async () => {
      await api()
        .get(`/api/v1/saved-plans/${planAId}`)
        .set('Authorization', `Bearer ${tokenB}`)
        .expect(404);
      const listB = await api()
        .get('/api/v1/saved-plans')
        .set('Authorization', `Bearer ${tokenB}`)
        .expect(200);
      expect(listB.body.data).toHaveLength(0);
    });

    it('user B cannot delete user A\'s plan', async () => {
      await api()
        .delete(`/api/v1/saved-plans/${planAId}`)
        .set('Authorization', `Bearer ${tokenB}`)
        .expect(404);
    });
  });

  it('GET /universities returns a paginated envelope', async () => {
    const res = await api().get('/api/v1/universities?limit=5').expect(200);
    expect(res.body.success).toBe(true);
    expect(res.body.meta).toEqual(expect.objectContaining({ page: 1, limit: 5 }));
  });

  it('GET /calculations/assumptions exposes planning assumptions + disclaimer', async () => {
    const res = await api().get('/api/v1/calculations/assumptions').expect(200);
    expect(res.body.data.takeHomeRate).toBe(0.7);
    expect(res.body.data.disclaimer).toContain('educational estimates');
  });
});
