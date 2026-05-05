import { NextResponse } from "next/server";
import dbConnect from "@/app/config/dbConnect";
import Attendance from "@/app/models/Attendance";
import Student from "@/app/models/Student";
import { verifyAuth } from "@/app/lib/authHelper";
import mongoose from "mongoose";

export async function POST(req: Request) {
  try {
    const auth = verifyAuth(req);
    if (!auth || auth.role !== "admin") {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 });
    }

    const { studentId } = await req.json();

    if (!studentId) {
      return NextResponse.json({ message: "Student ID missing" }, { status: 400 });
    }

    await dbConnect();

    try {
      let student = null;
      // The QR code might contain either the MongoDB _id or the custom studentId (e.g. STU-1234)
      if (mongoose.Types.ObjectId.isValid(studentId)) {
        student = await Student.findById(studentId).lean();
      }
      if (!student) {
        student = await Student.findOne({ studentId }).lean();
      }

      if (!student) {
        return NextResponse.json({ 
          success: false,
          message: "Student record not found in database" 
        }, { status: 404 });
      }

      // Check for existing mark today (Regardless of subject)
      const startOfDay = new Date();
      startOfDay.setHours(0, 0, 0, 0);
      const endOfDay = new Date();
      endOfDay.setHours(23, 59, 59, 999);

      const existingToday = await Attendance.findOne({
        studentId: student._id, // Use the MongoDB _id to match consistently
        date: { $gte: startOfDay, $lte: endOfDay }
      });

      if (existingToday) {
        return NextResponse.json({ 
          success: false,
          message: "Attendance already marked for this student today" 
        }, { status: 400 });
      }

      // Mark attendance
      await Attendance.create({
        studentId: student._id,
        studentName: student.fullName || "Unknown",
        studentPhone: student.phone || "N/A",
        date: new Date()
      });

      return NextResponse.json({ 
        success: true, 
        message: `Attendance marked for ${student.fullName}` 
      });

    } catch (dbErr) {
      console.error("Attendance Error:", dbErr);
      return NextResponse.json({ 
        success: false,
        message: "Database error or invalid Student ID" 
      }, { status: 500 });
    }
  } catch (error) {
    return NextResponse.json({ message: (error as Error).message }, { status: 500 });
  }
}

export async function OPTIONS() {
  return new NextResponse(null, {
    status: 204,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
    },
  });
}
