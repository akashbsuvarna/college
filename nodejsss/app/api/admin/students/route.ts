import { NextResponse } from "next/server";
import bcrypt from "bcryptjs";
import dbConnect from "@/app/config/dbConnect";
import Student from "@/app/models/Student";
import { verifyAuth } from "@/app/lib/authHelper";

export async function GET(req: Request) {
  try {
    const auth = verifyAuth(req);
    if (!auth || auth.role !== "admin") {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 });
    }

    const { searchParams } = new URL(req.url);
    const status = searchParams.get("status");

    await dbConnect();
    
    let query: any = {};
    if (status === "pending") {
      query.status = "pending";
    } else if (status === "active") {
      query.status = "active";
    } else {
      // By default, hide pending and rejected students
      query.status = { $nin: ["pending", "rejected"] };
    }

    const students = await Student.find(query).select("-password").sort({ createdAt: -1 });
    return NextResponse.json(students);
  } catch (error) {
    return NextResponse.json({ message: (error as Error).message }, { status: 500 });
  }
}

export async function POST(req: Request) {
  try {
    const auth = verifyAuth(req);
    if (!auth || auth.role !== "admin") {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 });
    }

    await dbConnect();
    const body = await req.json();

    // Auto-generate password from DOB (format: DDMMYYYY)
    // DOB stored as "DD-MM-YYYY" → password "DDMMYYYY"
    if (!body.dob) {
      return NextResponse.json({ message: "Date of Birth is required to generate student password." }, { status: 400 });
    }
    // Remove all dashes and slashes: "01-01-2003" → "01012003"
    const dobPassword = body.dob.replace(/[-/\s]/g, "");
    console.log(`[Student Create] Phone: ${body.phone} | DOB: ${body.dob} | Password set to: ${dobPassword}`);
    const salt = await bcrypt.genSalt(10);
    body.password = await bcrypt.hash(dobPassword, salt);

    // Generate studentId if not provided or empty
    if (!body.studentId || body.studentId.trim() === "") {
      body.studentId = "STU-" + Date.now().toString().substring(6);
    }

    const student = await Student.create(body);
    const studentObj = student.toObject();
    delete studentObj.password;

    return NextResponse.json(studentObj, { status: 201 });
  } catch (error) {
    return NextResponse.json({ message: (error as Error).message }, { status: 500 });
  }
}
