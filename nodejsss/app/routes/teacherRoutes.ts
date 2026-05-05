import { Router } from "express";
import {
  getTeachers,
  createTeacher,
  updateTeacher,
  deleteTeacher,
} from "../controllers/teacherController";
import { auth, adminOnly } from "../middleware/auth";

const router = Router();

router.get("/", auth, adminOnly, getTeachers);
router.post("/", auth, adminOnly, createTeacher);
router.put("/:id", auth, adminOnly, updateTeacher);
router.delete("/:id", auth, adminOnly, deleteTeacher);

export default router;
