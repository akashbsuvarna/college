import { NextResponse } from "next/server";
import Student from "../../../models/Student";
import Teacher from "../../../models/Teacher";
import Course from "../../../models/Course";
import Subject from "../../../models/Subject";
import { connectDB } from "../../../config/db";

export async function GET() {
  try {
    await connectDB();

    const studentCount = await Student.countDocuments();
    const teacherCount = await Teacher.countDocuments();
    const activeStudents = await Student.countDocuments({ status: "active" });
    const pendingStudents = await Student.countDocuments({ status: "pending" });
    const inactiveStudents = studentCount - activeStudents - pendingStudents;

    const courseCount = await Course.countDocuments().catch(() => 0);
    const subjectCount = await Subject.countDocuments().catch(() => 0);

    // Recent activities from last created students/teachers
    const recentStudents = await Student.find()
      .sort({ createdAt: -1 })
      .limit(2)
      .select("fullName createdAt status");
    const recentTeachers = await Teacher.find()
      .sort({ createdAt: -1 })
      .limit(2)
      .select("fullName createdAt");

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
      recentActivities,
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
