import { NextResponse } from "next/server";
import Student from "@/app/models/Student";
import Teacher from "@/app/models/Teacher";
import Course from "@/app/models/Course";
import Subject from "@/app/models/Subject";
import dbConnect from "@/app/config/dbConnect";

export async function GET() {
  try {
    await dbConnect();

    const [
      studentCount,
      teacherCount,
      activeStudents,
      pendingStudents,
      recentStudents,
      recentTeachers,
      courseCount,
      subjectCount
    ] = await Promise.all([
      Student.countDocuments(),
      Teacher.countDocuments(),
      Student.countDocuments({ status: "active" }),
      Student.countDocuments({ status: "pending" }),
      Student.find().sort({ createdAt: -1 }).limit(2).select("fullName createdAt status"),
      Teacher.find().sort({ createdAt: -1 }).limit(2).select("fullName createdAt"),
      Course.countDocuments().catch(() => 0),
      Subject.countDocuments().catch(() => 0)
    ]);

    const inactiveStudents = studentCount - activeStudents - pendingStudents;

    const recentActivities: any[] = [];

    for (const s of recentStudents) {
      recentActivities.push({
        title: s.status === "pending" ? "New student registration" : "Student joined",
        subtitle: `${s.fullName} ${s.status === "pending" ? "requested for admission" : "was added"}`,
        time: _timeAgo(s.createdAt),
        type: "student",
      });
    }

    for (const t of recentTeachers) {
      recentActivities.push({
        title: "Teacher joined",
        subtitle: `${t.fullName} joined the department`,
        time: _timeAgo(t.createdAt),
        type: "teacher",
      });
    }

    // Sort by most recent (this is a simple placeholder sort)
    recentActivities.sort((a, b) => 0);

    return NextResponse.json({
      totalStudents: studentCount,
      totalTeachers: teacherCount,
      totalCourses: courseCount,
      totalSubjects: subjectCount,
      activeStudents,
      activeTeachers: teacherCount,
      pendingStudents,
      inactiveStudents: inactiveStudents > 0 ? inactiveStudents : 0,
      attendanceRate: 82.0,
      presentCount: Math.round(activeStudents * 0.82),
      absentCount: Math.round(activeStudents * 0.18),
      weeklyAttendance: [
        { day: "Mon", percentage: 70 },
        { day: "Tue", percentage: 85 },
        { day: "Wed", percentage: 82 },
        { day: "Thu", percentage: 78 },
        { day: "Fri", percentage: 92 },
        { day: "Sat", percentage: 88 },
      ],
      recentActivities,
      pendingRequests: [
        { name: "mohan", course: "BCA", semester: 3, email: "abcd@gmail.com", phone: "987654321" },
        { name: "rohan", course: "BBA", semester: 1, email: "rohan@gmail.com", phone: "987654322" },
      ],
    });
  } catch (error: any) {
    return NextResponse.json(
      { message: "Server error", detail: error.message },
      { status: 500 }
    );
  }
}

function _timeAgo(date: Date): string {
  if (!date) return "recently";
  const now = new Date();
  const diff = Math.floor((now.getTime() - new Date(date).getTime()) / 60000);
  if (diff < 1) return "just now";
  if (diff < 60) return `${diff} min ago`;
  if (diff < 1440) return `${Math.floor(diff / 60)} hours ago`;
  return `${Math.floor(diff / 1440)} days ago`;
}
