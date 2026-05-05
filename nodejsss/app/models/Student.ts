import mongoose, { Schema, Document } from "mongoose";

export interface IStudent extends Document {
  fullName: string;
  email: string;
  phone: string;
  dob: string;
  password: string;
  caste: string;
  bloodGroup: string;
  permanentAddress: string;
  studentId?: string;
  father: {
    name: string;
    occupation: string;
    mobile: string;
  };
  mother: {
    name: string;
    occupation: string;
    mobile: string;
  };
  academic: {
    course: string;
    semester: number;
  };
  sslc: {
    school: string;
    percentage: number;
    board: string;
  };
  puc: {
    college: string;
    percentage: number;
    course: string;
  };
  status: "active" | "graduated" | "dropped" | "pending" | "rejected";
  createdAt: Date;
  updatedAt: Date;
}

const StudentSchema: Schema = new Schema(
  {
    fullName: { type: String, required: true },
    studentId: { type: String, unique: true, sparse: true },
    email: { type: String, required: true, unique: true },
    phone: { type: String, required: true },
    dob: { type: String, required: true }, // Added dob
    password: { type: String, required: true },
    caste: { type: String, default: "" },
    bloodGroup: { type: String, default: "Opos" },
    permanentAddress: { type: String, default: "" },
    father: {
      name: { type: String, default: "" },
      occupation: { type: String, default: "" },
      mobile: { type: String, default: "" },
    },
    mother: {
      name: { type: String, default: "" },
      occupation: { type: String, default: "" },
      mobile: { type: String, default: "" },
    },
    academic: {
      course: { type: String, default: "" },
      semester: { type: Number, default: 1 },
    },
    sslc: {
      school: { type: String, default: "" },
      percentage: { type: Number, default: 0 },
      board: { type: String, default: "" },
    },
    puc: {
      college: { type: String, default: "" },
      percentage: { type: Number, default: 0 },
      course: { type: String, default: "" },
    },
    status: {
      type: String,
      enum: ["active", "graduated", "dropped", "pending", "rejected"],
      default: "active",
    },
  },
  { timestamps: true }
);

// Auto-generate studentId if missing before saving
StudentSchema.pre("save", function (this: any) {
  if (!this.studentId || this.studentId.trim() === "") {
    this.studentId = "STU-" + Date.now().toString().substring(6);
  }
});

// Index on phone for student login lookup
StudentSchema.index({ phone: 1 });

// Delete the existing model to ensure schema updates take effect without restarting the server
delete mongoose.models.Student;

export default mongoose.models.Student || mongoose.model<IStudent>("Student", StudentSchema);
