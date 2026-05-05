import { NextResponse } from "next/server";
import bcrypt from "bcryptjs";
import dbConnect from "@/app/config/dbConnect";
import Teacher from "@/app/models/Teacher";
import { verifyAuth } from "@/app/lib/authHelper";

export async function GET(req: Request) {
  try {
    const auth = verifyAuth(req);
    if (!auth || auth.role !== "admin") {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 });
    }

    await dbConnect();
    const teachers = await Teacher.find().sort({ createdAt: -1 });
    return NextResponse.json(teachers);
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
    
    // Set default password "12345678" for new teachers
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash("12345678", salt);
    body.password = hashedPassword;

    const teacher = await Teacher.create(body);
    return NextResponse.json(teacher, { status: 201 });
  } catch (error) {
    return NextResponse.json({ message: (error as Error).message }, { status: 500 });
  }
}
