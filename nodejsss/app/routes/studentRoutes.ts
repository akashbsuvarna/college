import { Router } from "express";
import {
  getStudents,
  getStudentById,
  createStudent,
  updateStudent,
  deleteStudent,
} from "../controllers/studentController";
import { auth, adminOnly } from "../middleware/auth";

const router = Router();

/**
 * @openapi
 * /api/students:
 *   get:
 *     tags:
 *       - Students
 *     summary: Get all students
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of students
 */
router.get("/", auth, adminOnly, getStudents);

/**
 * @openapi
 * /api/students/{id}:
 *   get:
 *     tags:
 *       - Students
 *     summary: Get student by ID
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Student details
 */
router.get("/:id", auth, adminOnly, getStudentById);

/**
 * @openapi
 * /api/students:
 *   post:
 *     tags:
 *       - Students
 *     summary: Create new student
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *     responses:
 *       201:
 *         description: Student created
 */
router.post("/", auth, adminOnly, createStudent);

/**
 * @openapi
 * /api/students/{id}:
 *   put:
 *     tags:
 *       - Students
 *     summary: Update student
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *     responses:
 *       200:
 *         description: Student updated
 */
router.put("/:id", auth, adminOnly, updateStudent);

/**
 * @openapi
 * /api/students/{id}:
 *   delete:
 *     tags:
 *       - Students
 *     summary: Delete student
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Student deleted
 */
router.delete("/:id", auth, adminOnly, deleteStudent);

export default router;
