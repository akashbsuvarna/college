import mongoose from "mongoose";

const subjectSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, "Subject name is required"],
    trim: true,
  },
  code: {
    type: String,
    unique: true,
    required: [true, "Subject code is required"],
  },
  courseId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Course",
    required: [true, "Course association is required"],
  },
  credits: {
    type: Number,
    default: 3,
  }
}, { timestamps: true });

const Subject = mongoose.models.Subject || mongoose.model("Subject", subjectSchema);
export default Subject;
