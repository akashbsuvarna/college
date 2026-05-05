import { NextResponse } from "next/server";
import dbConnect from "@/app/config/dbConnect";
import Student from "@/app/models/Student";
import { verifyAuth } from "@/app/lib/authHelper";

export async function PUT(req: Request, { params }: { params: Promise<{ id: string }> }) {
  try {
    const auth = verifyAuth(req);
    if (!auth || auth.role !== "admin") {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 });
    }

    await dbConnect();
    const body = await req.json();
    
    const { course, semester } = body;
    
    if (!course || !semester) {
      return NextResponse.json({ message: "Course and semester are required to accept a student." }, { status: 400 });
    }

    const { id } = await params;
    const student = await Student.findByIdAndUpdate(
      id, 
      { 
        $set: { 
          status: "active",
          "academic.course": course,
          "academic.semester": semester
        } 
      }, 
      { new: true }
    ).select('-password');

    if (!student) {
      return NextResponse.json({ message: "Student not found" }, { status: 404 });
    }

    return NextResponse.json(student);
  } catch (error) {
    return NextResponse.json({ message: (error as Error).message }, { status: 500 });
  }
}
