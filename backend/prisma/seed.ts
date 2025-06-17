import { PrismaClient, Prisma } from '@prisma/client';
import bcrypt from 'bcryptjs';
import 'dotenv/config';

const prisma = new PrismaClient();

async function main() {
  console.log('Start seeding...');

  // 1. Clear existing data
  await prisma.note.deleteMany({});
  await prisma.peakSchedule.deleteMany({});
  await prisma.user.deleteMany({});
  console.log('Cleared existing data.');

  // 2. Define Public Holidays for 2025
  const publicHolidays2025 = [
    new Date('2025-01-01T00:00:00.000Z'),
    new Date('2025-02-12T00:00:00.000Z'),
    new Date('2025-04-07T00:00:00.000Z'),
    new Date('2025-04-13T00:00:00.000Z'), new Date('2025-04-14T00:00:00.000Z'), new Date('2025-04-15T00:00:00.000Z'),
    new Date('2025-05-01T00:00:00.000Z'), new Date('2025-05-05T00:00:00.000Z'),
    new Date('2025-06-03T00:00:00.000Z'),
    new Date('2025-07-28T00:00:00.000Z'), new Date('2025-07-29T00:00:00.000Z'),
    new Date('2025-08-12T00:00:00.000Z'),
    new Date('2025-10-13T00:00:00.000Z'), new Date('2025-10-23T00:00:00.000Z'),
    new Date('2025-12-05T00:00:00.000Z'), new Date('2025-12-10T00:00:00.000Z'), new Date('2025-12-31T00:00:00.000Z'),
  ];

  const schedulesToCreate: Prisma.PeakScheduleCreateManyInput[] = [];

  // --- Weekday Schedules (Monday - Friday) ---
  const weekdays = [1, 2, 3, 4, 5];

  weekdays.forEach(day => {
    // --- MEA Schedule ---
    // On-Peak Periods
    schedulesToCreate.push({ provider: 'MEA', dayOfWeek: day, startTime: '06:00', endTime: '10:00', isPeak: true });
    schedulesToCreate.push({ provider: 'MEA', dayOfWeek: day, startTime: '17:00', endTime: '21:00', isPeak: true });
    // Off-Peak Periods
    schedulesToCreate.push({ provider: 'MEA', dayOfWeek: day, startTime: '00:00', endTime: '06:00', isPeak: false });
    schedulesToCreate.push({ provider: 'MEA', dayOfWeek: day, startTime: '10:00', endTime: '17:00', isPeak: false });
    schedulesToCreate.push({ provider: 'MEA', dayOfWeek: day, startTime: '21:00', endTime: '23:59', isPeak: false });

    // --- PEA Schedule ---
    // On-Peak Periods
    schedulesToCreate.push({ provider: 'PEA', dayOfWeek: day, startTime: '07:00', endTime: '10:00', isPeak: true });
    schedulesToCreate.push({ provider: 'PEA', dayOfWeek: day, startTime: '17:00', endTime: '21:00', isPeak: true });
    // Off-Peak Periods
    schedulesToCreate.push({ provider: 'PEA', dayOfWeek: day, startTime: '00:00', endTime: '07:00', isPeak: false });
    schedulesToCreate.push({ provider: 'PEA', dayOfWeek: day, startTime: '10:00', endTime: '17:00', isPeak: false });
    schedulesToCreate.push({ provider: 'PEA', dayOfWeek: day, startTime: '21:00', endTime: '23:59', isPeak: false });
  });

  // --- Weekend Schedule (Saturday & Sunday) ---
  const weekends = [0, 6];
  weekends.forEach(day => {
    // All day off-peak
    schedulesToCreate.push({ provider: 'MEA', dayOfWeek: day, startTime: '00:00', endTime: '23:59', isPeak: false });
    schedulesToCreate.push({ provider: 'PEA', dayOfWeek: day, startTime: '00:00', endTime: '23:59', isPeak: false });
  });

  // --- Holiday Schedule ---
  publicHolidays2025.forEach(holiday => {
    // All day off-peak
    schedulesToCreate.push({ provider: 'MEA', specificDate: holiday, startTime: '00:00', endTime: '23:59', isPeak: false });
    schedulesToCreate.push({ provider: 'PEA', specificDate: holiday, startTime: '00:00', endTime: '23:59', isPeak: false });
  });

  await prisma.peakSchedule.createMany({ data: schedulesToCreate });
  console.log(`Seeded ${schedulesToCreate.length} new schedule rules.`);

  // --- Seeding Test User ---
  const salt = await bcrypt.genSalt(10);
  const hashedPassword = await bcrypt.hash('password12345', salt);

  const user1 = await prisma.user.create({
    data: {
      email: 'test@test.com',
      name: 'Test User',
      password: hashedPassword,
      provider: 'MEA', // Default test user to MEA
    },
  });
  console.log(`Created user: ${user1.name}`);
}

main()
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });