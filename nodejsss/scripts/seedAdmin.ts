import mongoose from "mongoose";
import bcrypt from "bcryptjs";
import dotenv from "dotenv";
import Admin from "../app/models/Admin";

dotenv.config();

const seedAdmin = async () => {
    try {
        const uri = process.env.MONGODB_URI || "mongodb://localhost:27017/";
        await mongoose.connect(uri);
        console.log("Connected to MongoDB...");

        const email = "admin@college.com";
        const password = "admin123";

        const existingAdmin = await Admin.findOne({ email });
        if (existingAdmin) {
            console.log("Admin already exists!");
        } else {
            const hashedPassword = await bcrypt.hash(password, 10);
            await Admin.create({
                email,
                password: hashedPassword
            });
            console.log("Admin seeded successfully!");
            console.log(`Email: ${email}`);
            console.log(`Password: ${password}`);
        }

        await mongoose.disconnect();
        console.log("Disconnected from MongoDB.");
    } catch (error) {
        console.error("Error seeding admin:", error);
        process.exit(1);
    }
};

seedAdmin();
