import { NextResponse } from "next/server";
import dbConnect from "@/app/config/dbConnect";
import Subject from "@/app/models/Subject";
import { verifyAuth } from "@/app/lib/authHelper";

export async function GET(req: Request) {
  try {
    const auth = verifyAuth(req);
    if (!auth || auth.role !== "admin") {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 });
    }

    const { searchParams } = new URL(req.url);
    const courseId = searchParams.get("courseId");
    
    await dbConnect();
    const query = courseId ? { courseId } : {};
    const subjects = await Subject.find(query).populate("courseId").sort({ createdAt: -1 });
    return NextResponse.json(subjects);
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
    const subject = await Subject.create(body);
    return NextResponse.json(subject, { status: 201 });
  } catch (error) {
    return NextResponse.json({ message: (error as Error).message }, { status: 500 });
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
