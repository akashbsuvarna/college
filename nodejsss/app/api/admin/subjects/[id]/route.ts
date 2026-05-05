import { NextResponse } from "next/server";
import dbConnect from "@/app/config/dbConnect";
import Subject from "@/app/models/Subject";
import { verifyAuth } from "@/app/lib/authHelper";

export async function PUT(req: Request, { params }: { params: Promise<{ id: string }> }) {
  try {
    const auth = verifyAuth(req);
    if (!auth || auth.role !== "admin") {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 });
    }

    await dbConnect();
    const body = await req.json();
    const { id } = await params;
    const subject = await Subject.findByIdAndUpdate(id, body, { new: true });
    if (!subject) {
      return NextResponse.json({ message: "Subject not found" }, { status: 404 });
    }
    return NextResponse.json(subject);
  } catch (error) {
    return NextResponse.json({ message: (error as Error).message }, { status: 500 });
  }
}

export async function DELETE(req: Request, { params }: { params: Promise<{ id: string }> }) {
  try {
    const auth = verifyAuth(req);
    if (!auth || auth.role !== "admin") {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 });
    }

    await dbConnect();
    const { id } = await params;
    const subject = await Subject.findByIdAndDelete(id);
    if (!subject) {
      return NextResponse.json({ message: "Subject not found" }, { status: 404 });
    }
    return NextResponse.json({ message: "Subject deleted successfully" });
  } catch (error) {
    return NextResponse.json({ message: (error as Error).message }, { status: 500 });
  }
}
