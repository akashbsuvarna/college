import { NextResponse } from "next/server";
import dbConnect from "@/app/config/dbConnect";
import Notification from "@/app/models/Notification";
import { verifyAuth } from "@/app/lib/authHelper";

export async function GET(req: Request) {
  try {
    await dbConnect();
    const notifications = await Notification.find().sort({ createdAt: -1 });
    return NextResponse.json(notifications);
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
    const notification = await Notification.create({
      ...body,
      sentBy: auth.id
    });
    return NextResponse.json(notification, { status: 201 });
  } catch (error) {
    return NextResponse.json({ message: (error as Error).message }, { status: 500 });
  }
}
