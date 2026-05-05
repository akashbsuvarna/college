import { NextResponse } from "next/server";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import dbConnect from "@/app/config/dbConnect";
import Student from "@/app/models/Student";

export async function POST(req: Request) {
  try {
    await dbConnect();
    const { phone, password } = await req.json();
    const cleanPhone = phone?.toString().trim();

    if (!cleanPhone || !password) {
      return NextResponse.json(
        { message: "Phone number and password are required" },
        { status: 400 }
      );
    }

    // Find student by their phone number (username)
    console.log(`[Student Login Attempt] Original: "${phone}" | Cleaned: "${cleanPhone}"`);
    
    // Try to find by exact match, or match without +91 prefix
    let student = await Student.findOne({ phone: cleanPhone });
    
    if (!student && cleanPhone.startsWith("+91")) {
      const shortPhone = cleanPhone.substring(3);
      console.log(`[Student Login] Trying match without +91: "${shortPhone}"`);
      student = await Student.findOne({ phone: shortPhone });
    } else if (!student && cleanPhone.length === 10) {
      // Try with +91 if they only entered 10 digits
      const longPhone = "+91" + cleanPhone;
      console.log(`[Student Login] Trying match with +91: "${longPhone}"`);
      student = await Student.findOne({ phone: longPhone });
    }

    if (!student) {
      console.log(`[Student Login Failed] User not found: ${cleanPhone}`);
      return NextResponse.json(
        { message: "Invalid username or password" },
        { status: 401 }
      );
    }

    // Check if the student is pending or rejected
    if (student.status === "pending") {
      console.log(`[Student Login Failed] Pending registration: ${cleanPhone}`);
      return NextResponse.json(
        { message: "Your registration is pending approval by an administrator." },
        { status: 403 }
      );
    }

    if (student.status === "rejected") {
      console.log(`[Student Login Failed] Rejected registration: ${cleanPhone}`);
      return NextResponse.json(
        { message: "Your registration has been rejected. Please contact the administration." },
        { status: 403 }
      );
    }

    // Verify password
    // Clean input password if they typed it with dashes/slashes (very common)
    const cleanInputPassword = password?.toString().replace(/[-/\s]/g, "");
    
    console.log(`[Student Login Trace] Input: "${password}" -> Cleaned: "${cleanInputPassword}"`);
    console.log(`[Student Login Trace] Comparing against hash starting with: ${student.password.substring(0, 10)}...`);
    
    const isMatch = await bcrypt.compare(cleanInputPassword, student.password);
    console.log(`[Student Login Result] Match: ${isMatch}`);
    
    if (!isMatch) {
      console.log(`[Student Login Failed] Password mismatch for: ${student.fullName}`);
      return NextResponse.json(
        { message: "Invalid credentials" },
        { status: 401 }
      );
    }

    // Generate JWT
    const token = jwt.sign(
      { id: student._id, role: "student" },
      process.env.JWT_SECRET || "default_secret",
      { expiresIn: "7d" }
    );

    // Return student info without password
    const studentObj = student.toObject();
    delete studentObj.password;

    return NextResponse.json({
      success: true,
      token,
      student: studentObj,
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
