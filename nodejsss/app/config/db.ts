import mongoose from "mongoose";

export const connectDB = async () => {
  try {
    const mongoUri = process.env.MONGODB_URI || "mongodb://localhost:27017/college_management";
    await mongoose.connect(mongoUri);
    console.log("DB Connected to:", mongoUri);
  } catch (error) {
    console.error("DB Connection Error:", error);
  }
};