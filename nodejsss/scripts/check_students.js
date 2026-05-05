const { MongoClient } = require('mongodb');

const MONGODB_URI = 'mongodb://localhost:27017/college_management';

async function checkStudents() {
  const client = new MongoClient(MONGODB_URI);
  try {
    await client.connect();
    const db = client.db('college_management');
    const students = db.collection('students');
    
    const all = await students.find({}).toArray();
    console.log('--- STUDENT RECORDS ---');
    all.forEach(s => {
      console.log(`Name: ${s.fullName}, Phone: "${s.phone}", DOB: ${s.dob}, HasPassword: ${!!s.password}`);
    });
    console.log('-----------------------');
  } catch (err) {
    console.error(err);
  } finally {
    await client.close();
  }
}

checkStudents();
