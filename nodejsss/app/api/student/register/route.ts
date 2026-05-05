import { NextResponse } from "next/server";
// Trigger reload
import bcrypt from "bcryptjs";
import dbConnect from "@/app/config/dbConnect";
import Student from "@/app/models/Student";

export async function POST(req: Request) {
  try {
    await dbConnect();
    const body = await req.json();

    // Auto-generate password from DOB (format: DDMMYYYY)
    if (!body.dob) {
      return NextResponse.json({ message: "Date of Birth is required." }, { status: 400 });
    }
    const dobPassword = body.dob.replace(/[-/\s]/g, "");
    const salt = await bcrypt.genSalt(10);
    body.password = await bcrypt.hash(dobPassword, salt);

    // Auto-generate studentId
    body.studentId = "STU-" + Date.now().toString().substring(6);

    // Set status to pending
    body.status = "pending";

    const student = await Student.create(body);
    const studentObj = student.toObject();
    delete studentObj.password;

    return NextResponse.json(studentObj, { status: 201 });
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
