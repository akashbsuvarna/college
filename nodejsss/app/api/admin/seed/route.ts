import { NextResponse } from "next/server";
import bcrypt from "bcryptjs";
import dbConnect from "@/app/config/dbConnect";
import Admin from "@/app/models/Admin";

export async function GET() {
  try {
    await dbConnect();

    const email = "admin@college.com";
    const password = "admin123";

    let existingAdmin = await Admin.findOne({ email });
    const hashedPassword = await bcrypt.hash(password, 10);

    if (existingAdmin) {
      existingAdmin.password = hashedPassword;
      await existingAdmin.save();
      return NextResponse.json({ message: "Admin password reset successfully!", email, password });
    }

    await Admin.create({
      email,
      password: hashedPassword
    });

    return NextResponse.json({
      message: "Admin seeded successfully!",
      email,
      password
    });
  } catch (error) {
    return NextResponse.json({ message: (error as Error).message }, { status: 500 });
  }
}
