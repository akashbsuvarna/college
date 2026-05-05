import mongoose from "mongoose";

const teacherSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, "Name is required"],
  },
  email: {
    type: String,
    required: [true, "Email is required"],
    unique: true,
  },
  password: {
    type: String,
    required: [true, "Password is required"],
  },
  employeeId: {
    type: String,
    required: [true, "Employee ID is required"],
    unique: true,
  },
  designation: {
    type: String,
    required: [true, "Designation is required"],
  },
  department: {
    type: String,
    required: [true, "Department is required"],
  },
  phone: {
    type: String,
    required: [true, "Phone number is required"],
    unique: true,
  },
  dob: {
    type: String,
    required: [true, "Date of birth is required"],
  },
  joiningDate: {
    type: String,
  },
  status: {
    type: String,
    enum: ["active", "inactive", "on_leave"],
    default: "active",
  },
  coursesAssigned: {
    type: Number,
    default: 0,
  },
  qualification: {
    type: String,
  },
  subjects: {
    type: [String],
    default: [],
  },
}, { timestamps: true });

const Teacher = mongoose.models.Teacher || mongoose.model("Teacher", teacherSchema);

export default Teacher;
