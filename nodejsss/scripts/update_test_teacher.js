import mongoose from "mongoose";

async function updateTestTeacher() {
  await mongoose.connect('mongodb://localhost:27017/college_management');
  const db = mongoose.connection.db;
  await db.collection('teachers').updateOne(
    { email: 'teacher@example.com' },
    { $set: { phone: '1234567890', dob: '1980-01-01' } }
  );
  console.log('Updated test teacher with phone and dob');
  process.exit(0);
}

updateTestTeacher();
