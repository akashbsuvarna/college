import { NextResponse } from "next/server";
import jwt from "jsonwebtoken";
import dbConnect from "@/app/config/dbConnect";
import Attendance from "@/app/models/Attendance";

export async function POST(req: Request) {
  try {
    const { token, studentId } = await req.json();

    if (!token || !studentId) {
      return NextResponse.json({ message: "Token and studentId are required" }, { status: 400 });
    }

    // Verify the QR token
    let decoded: any;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET || "default_secret");
    } catch (error) {
      return NextResponse.json({ message: "Invalid or expired QR code" }, { status: 400 });
    }

    if (decoded.type !== "attendance") {
      return NextResponse.json({ message: "Invalid token type" }, { status: 400 });
    }

    await dbConnect();

    // Calculate start and end of current day
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date();
    endOfDay.setHours(23, 59, 59, 999);

    // Check if attendance already marked for this Student + Subject + Day
    const existingToday = await Attendance.findOne({
      studentId,
      subjectId: decoded.subjectId,
      date: { $gte: startOfDay, $lte: endOfDay }
    });

    if (existingToday) {
      return NextResponse.json({ 
        success: false,
        message: "Attendance already marked for this subject today" 
      }, { status: 400 });
    }

    // Check if attendance already marked for this specific session (redundant but safe)
    const existingSession = await Attendance.findOne({
      studentId,
      sessionId: decoded.sessionId
    });

    if (existingSession) {
      return NextResponse.json({ 
        success: false,
        message: "Attendance already marked for this session" 
      }, { status: 400 });
    }

    // Mark attendance
    const attendance = await Attendance.create({
      studentId,
      subjectId: decoded.subjectId,
      sessionId: decoded.sessionId,
      status: "present",
      date: new Date()
    });

    return NextResponse.json({
      success: true,
      message: "Attendance marked successfully",
      attendance
    });
  } catch (error) {
    return NextResponse.json({ message: (error as Error).message }, { status: 500 });
  }
}
