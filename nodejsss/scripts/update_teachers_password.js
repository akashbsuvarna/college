import mongoose from "mongoose";
import bcrypt from "bcryptjs";
import dotenv from "dotenv";
import path from "path";

// Load env vars
dotenv.config({ path: path.resolve(process.cwd(), ".env") });

async function updateTeachers() {
  try {
    const MONGODB_URI = process.env.MONGODB_URI;
    if (!MONGODB_URI) {
      throw new Error("Please define the MONGODB_URI environment variable inside .env.local");
    }

    await mongoose.connect(MONGODB_URI);
    console.log("Connected to MongoDB.");

    // Dynamic import to avoid next.js specific issues in standalone script
    const teacherSchema = new mongoose.Schema({}, { strict: false });
    const Teacher = mongoose.models.Teacher || mongoose.model("Teacher", teacherSchema);

    const teachers = await Teacher.find({ password: { $exists: false } });
    console.log(`Found ${teachers.length} teachers without a password.`);

    if (teachers.length > 0) {
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash("12345678", salt);

      const result = await Teacher.updateMany(
        { password: { $exists: false } },
        { $set: { password: hashedPassword } }
      );

      console.log(`Successfully updated ${result.modifiedCount} teachers with default password '12345678'.`);
    } else {
      console.log("All teachers already have a password.");
    }

    await mongoose.disconnect();
    console.log("Disconnected from MongoDB.");
  } catch (error) {
    console.error("Error updating teachers:", error);
    process.exit(1);
  }
}

updateTeachers();
