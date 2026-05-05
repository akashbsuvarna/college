import { NextResponse } from "next/server";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import dbConnect from "@/app/config/dbConnect";
import Teacher from "@/app/models/Teacher";

export async function POST(req: Request) {
  try {
    await dbConnect();
    const { phone, dob } = await req.json();
    const cleanPhone = phone?.toString().trim();

    if (!cleanPhone || !dob) {
      return NextResponse.json(
        { message: "Phone number and date of birth are required" },
        { status: 400 }
      );
    }

    const teacher = await Teacher.findOne({ phone: cleanPhone });

    if (!teacher) {
      return NextResponse.json(
        { message: "Invalid phone number or date of birth" },
        { status: 401 }
      );
    }

    if (teacher.status !== "active") {
      return NextResponse.json(
        { message: "Your account is not active. Please contact administration." },
        { status: 403 }
      );
    }

    // Compare DOB directly (as strings)
    if (teacher.dob !== dob) {
      return NextResponse.json(
        { message: "Invalid phone number or date of birth" },
        { status: 401 }
      );
    }

    const token = jwt.sign(
      { id: teacher._id, role: "teacher" },
      process.env.JWT_SECRET || "default_secret",
      { expiresIn: "7d" }
    );

    const teacherObj = teacher.toObject();
    delete teacherObj.password;

    return NextResponse.json({
      success: true,
      token,
      teacher: teacherObj,
    });
  } catch (error) {
    return NextResponse.json(
      { message: (error as Error).message },
      { status: 500 }
    );
  }
}

export async function OPTIONS() {
  return new NextResponse(null, {
    status: 204,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
    },
  });
}
