import { NextResponse } from "next/server";
import dbConnect from "@/app/config/dbConnect";
import Student from "@/app/models/Student";
import { verifyAuth } from "@/app/lib/authHelper";

export async function GET(req: Request) {
  try {
    const auth = verifyAuth(req);
    if (!auth || auth.role !== "student") {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 });
    }

    await dbConnect();
    const student = await Student.findById(auth.id).select("-password");
    if (!student) {
      return NextResponse.json({ message: "Student not found" }, { status: 404 });
    }

    return NextResponse.json(student);
  } catch (error) {
    return NextResponse.json(
      { message: (error as Error).message },
      { status: 500 }
    );
  }
}
