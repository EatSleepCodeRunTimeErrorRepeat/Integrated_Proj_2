// =================================================================
// File: prisma/seed.ts
// NOTE: Please CLOSE AND RESTART your code editor (e.g. VS Code),
//       then run `npx prisma generate` before seeding with 'npx prisma db seed'.
// =================================================================
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

  // 3. Define the schedule creation data with an explicit type
  const schedulesToCreate: Prisma.PeakScheduleCreateManyInput[] = [];

  [1, 2, 3, 4, 5].forEach(day => {
    schedulesToCreate.push({ provider: 'MEA', dayOfWeek: day, startTime: '09:00', endTime: '22:00', isPeak: true });
    schedulesToCreate.push({ provider: 'PEA', dayOfWeek: day, startTime: '09:00', endTime: '22:00', isPeak: true });
  });

  publicHolidays2025.forEach(holiday => {
      schedulesToCreate.push({ provider: 'MEA', specificDate: holiday, startTime: '00:00', endTime: '23:59', isPeak: false });
      schedulesToCreate.push({ provider: 'PEA', specificDate: holiday, startTime: '00:00', endTime: '23:59', isPeak: false });
  });

  await prisma.peakSchedule.createMany({ data: schedulesToCreate });
  console.log(`Seeded ${schedulesToCreate.length} schedule rules.`);

  // 4. Seed User
  const salt = await bcrypt.genSalt(10);
  const hashedPassword = await bcrypt.hash('password123', salt);

  const user1 = await prisma.user.upsert({
    where: { email: 'test@test.com' },
    update: {},
    create: {
      email: 'test@test.com',
      name: 'Test User',
      password: hashedPassword,
      provider: 'MEA',
      notificationsEnabled: true,
    },
  });
  console.log(`Created/updated user: ${user1.name}`);

  // 5. Seed Notes
  const defaultNotes = [
    { content: 'Avoid using the oven; use a microwave instead.', peakPeriod: 'ON_PEAK', authorId: user1.id, date: new Date() },
    { content: 'Postpone laundry until off-peak hours.', peakPeriod: 'ON_PEAK', authorId: user1.id, date: new Date() },
    { content: 'Charge electric vehicles now.', peakPeriod: 'OFF_PEAK', authorId: user1.id, date: new Date() },
    { content: 'Run the washing machine and dryer.', peakPeriod: 'OFF_PEAK', authorId: user1.id, date: new Date() },
  ];
  await prisma.note.createMany({ data: defaultNotes });
  console.log(`Created ${defaultNotes.length} notes for ${user1.name}`);

  await prisma.$disconnect();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
