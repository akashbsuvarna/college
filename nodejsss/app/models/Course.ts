import mongoose from "mongoose";

const courseSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, "Course title is required"],
    trim: true,
  },
  description: {
    type: String,
    required: [true, "Description is required"],
  },
  duration: {
    type: String,
    required: [true, "Duration is required"],
  },
  code: {
    type: String,
    unique: true,
    required: [true, "Course code is required"],
  }
}, { timestamps: true });

const Course = mongoose.models.Course || mongoose.model("Course", courseSchema);
export default Course;
