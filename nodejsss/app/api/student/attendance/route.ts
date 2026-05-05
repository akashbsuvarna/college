import { NextResponse } from "next/server";
import dbConnect from "@/app/config/dbConnect";
import Attendance from "@/app/models/Attendance";
import { verifyAuth } from "@/app/lib/authHelper";

export async function GET(req: Request) {
  try {
    const auth = verifyAuth(req);
    if (!auth || auth.role !== "student") {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 });
    }

    await dbConnect();
    const attendance = await Attendance.find({ studentId: auth.id })
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
