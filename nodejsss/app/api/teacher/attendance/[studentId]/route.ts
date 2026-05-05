import { NextResponse } from "next/server";
import dbConnect from "@/app/config/dbConnect";
import Attendance from "@/app/models/Attendance";
import { verifyAuth } from "@/app/lib/authHelper";

export async function GET(
  req: Request,
  { params }: { params: Promise<{ studentId: string }> }
) {
  try {
    const auth = verifyAuth(req);
    // Both admin and teacher can view student attendance details
    if (!auth || (auth.role !== "teacher" && auth.role !== "admin")) {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 });
    }

    const { studentId } = await params;
    if (!studentId) {
      return NextResponse.json({ message: "Student ID is required" }, { status: 400 });
    }

    await dbConnect();
    const attendance = await Attendance.find({ studentId })
      .populate("subjectId", "name code")
      .sort({ date: -1 });

    return NextResponse.json(attendance);
  } catch (error) {
    return NextResponse.json(
      { message: (error as Error).message },
      { status: 500 }
    );
  }
}
