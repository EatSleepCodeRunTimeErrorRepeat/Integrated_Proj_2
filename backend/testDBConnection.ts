import { PrismaClient } from '@prisma/client';
import 'dotenv/config';

// This script will try to connect and perform one simple query.
const prisma = new PrismaClient();

async function main() {
  console.log('Attempting to connect to the database to check credentials...');
  try {
    // We try a simple, low-impact query to verify the connection.
    const userCount = await prisma.user.count();
    console.log(`✅ --- SUCCESS! --- ✅`);
    console.log(`Successfully connected to the database.`);
    console.log(`Your database currently has ${userCount} users.`);
    console.log(`\nNow you can safely run: npx prisma db seed`);
  } catch (error) {
    console.error(`❌ --- DATABASE CONNECTION FAILED --- ❌`);
    console.error(`There is an issue with your database connection string in the .env file or your network settings.`);
    console.error(`\nHere is the full error message:`);
    console.error(error);
  } finally {
    await prisma.$disconnect();
  }
}

main();