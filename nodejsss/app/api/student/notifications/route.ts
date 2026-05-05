import { NextResponse } from "next/server";
import dbConnect from "@/app/config/dbConnect";
import Notification from "@/app/models/Notification";
import { verifyAuth } from "@/app/lib/authHelper";

export async function GET(req: Request) {
  try {
    const auth = verifyAuth(req);
    if (!auth || auth.role !== "student") {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 });
    }

    await dbConnect();
    // Get notifications targeted to "all" or "students"
    const notifications = await Notification.find({
      target: { $in: ["all", "students"] },
    }).sort({ createdAt: -1 });

    return NextResponse.json(notifications);
  } catch (error) {
    return NextResponse.json(
      { message: (error as Error).message },
      { status: 500 }
    );
  }
}
