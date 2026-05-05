import { NextResponse } from "next/server";
import jwt from "jsonwebtoken";
import QRCode from "qrcode";
import { verifyAuth } from "@/app/lib/authHelper";

export async function POST(req: Request) {
  try {
    const auth = verifyAuth(req);
    if (!auth || auth.role !== "admin") {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 });
    }

    const { subjectId, sessionId } = await req.json();
    if (!subjectId || !sessionId) {
      return NextResponse.json({ message: "subjectId and sessionId are required" }, { status: 400 });
    }

    // Generate a short-lived token (5 minutes) for the session
    const qrToken = jwt.sign(
      { subjectId, sessionId, type: "attendance" },
      process.env.JWT_SECRET || "default_secret",
      { expiresIn: "5m" }
    );

    // Generate QR Data URL
    const qrData = JSON.stringify({
      subjectId,
      sessionId,
      token: qrToken
    });
    
    const qrCodeUrl = await QRCode.toDataURL(qrData);

    return NextResponse.json({
      success: true,
      qrToken,
      qrCodeUrl,
      expiresIn: "5 minutes"
    });
  } catch (error) {
    return NextResponse.json({ message: (error as Error).message }, { status: 500 });
  }
}
