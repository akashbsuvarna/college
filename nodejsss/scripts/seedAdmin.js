const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
require("dotenv").config();

// Define schema directly to avoid import issues
const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: [true, "email is required"],
    unique: true
  },
  password: {
    type: String,
    required: [true, "password is required"],
  },
});

const User = mongoose.models.users || mongoose.model("users", userSchema);

const seedAdmin = async () => {
  try {
    const MONGODB_URI = process.env.MONGODB_URI || "mongodb://localhost:27017/";
    await mongoose.connect(MONGODB_URI);
    console.log("Connected to MongoDB for seeding...");

    const email = "akashbsuvarna@gmail.com";
    const password = "12345";

    // Check if admin already exists
    const existingAdmin = await User.findOne({ email });
    if (existingAdmin) {
      console.log("Admin already exists. Updating password...");
      const hashedPassword = await bcrypt.hash(password, 10);
      existingAdmin.password = hashedPassword;
      await existingAdmin.save();
      console.log("Admin password updated successfully.");
    } else {
      console.log("Creating new admin user...");
      const hashedPassword = await bcrypt.hash(password, 10);
      const newAdmin = new User({
        email,
        password: hashedPassword,
      });
      await newAdmin.save();
      console.log("Admin user created successfully.");
    }

    await mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error("Error seeding admin:", error);
    process.exit(1);
  }
};

seedAdmin();
