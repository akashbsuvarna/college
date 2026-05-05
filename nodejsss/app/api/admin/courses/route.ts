import { NextResponse } from "next/server";
import dbConnect from "@/app/config/dbConnect";
import Course from "@/app/models/Course";
import { verifyAuth } from "@/app/lib/authHelper";

export async function GET(req: Request) {
  try {
    // Making this endpoint public so students can fetch courses during registration

    await dbConnect();
    const courses = await Course.find().sort({ createdAt: -1 });
    return NextResponse.json(courses);
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
    const course = await Course.create(body);
    return NextResponse.json(course, { status: 201 });
  } catch (error) {
    return NextResponse.json({ message: (error as Error).message }, { status: 500 });
  }
}
