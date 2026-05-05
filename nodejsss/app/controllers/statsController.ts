import { Request, Response } from "express";
import Student from "../models/Student";
import Teacher from "../models/Teacher";

export const getDashboardStats = async (req: Request, res: Response) => {
  try {
    const studentCount = await Student.countDocuments();
    const teacherCount = await Teacher.countDocuments();
    
    // For now, let's mock the other stats or use defaults
    res.json({
      totalStudents: studentCount,
      totalTeachers: teacherCount,
      activeSessions: 12, // Mocked
      upcomingEvents: 4,  // Mocked
      recentActivity: [
        { id: "1", type: "student_added", message: "New student enrolled: John Doe", time: "2h ago" },
        { id: "2", type: "teacher_added", message: "New teacher joined: Sarah Smith", time: "5h ago" },
      ]
    });
  } catch (error) {
    res.status(500).json({ message: "Server error", detail: (error as Error).message });
  }
};
