const { MongoClient } = require('mongodb');

const MONGODB_URI = 'mongodb://localhost:27017/college_management';

async function clearStudents() {
  const client = new MongoClient(MONGODB_URI);
  try {
    await client.connect();
    console.log('Connected to MongoDB...');
    
    const db = client.db('college_management');
    const students = db.collection('students');
    
    const count = await students.countDocuments();
    console.log(`Found ${count} student(s) in the collection.`);
    
    if (count > 0) {
      await students.deleteMany({});
      console.log(`✅ Cleared all ${count} student records.`);
    } else {
      console.log('Collection already empty.');
    }

    // Also drop and recreate indexes to fix the studentId_1 unique index issue
    try {
      await students.dropIndex('studentId_1');
      console.log('✅ Dropped old studentId_1 index.');
    } catch (e) {
      console.log('No studentId_1 index to drop (or already clean).');
    }

    console.log('\nDone! You can now add fresh students from the admin panel.');
  } catch (err) {
    console.error('Error:', err.message);
  } finally {
    await client.close();
  }
}

clearStudents();
