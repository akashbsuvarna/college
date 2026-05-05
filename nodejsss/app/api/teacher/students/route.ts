import { NextResponse } from "next/server";
import dbConnect from "@/app/config/dbConnect";
import Student from "@/app/models/Student";
import { verifyAuth } from "@/app/lib/authHelper";

export async function GET(req: Request) {
  try {
    const auth = verifyAuth(req);
    if (!auth || auth.role !== "teacher") {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 });
    }

    await dbConnect();
    // Only return active students, or all. Since teachers might want to view all, let's fetch all.
    // Or we can just fetch students with status != "pending" && status != "rejected"
    const students = await Student.find({ status: { $nin: ["pending", "rejected"] } })
      .select("-password")
      .sort({ createdAt: -1 });
      
    return NextResponse.json(students);
  } catch (error) {
    return NextResponse.json({ message: (error as Error).message }, { status: 500 });
  }
}
