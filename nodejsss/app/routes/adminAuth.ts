import { Router } from "express";
import { loginAdmin, getAdminProfile } from "../controllers/adminController";
import { getDashboardStats } from "../controllers/statsController";
import { auth, adminOnly } from "../middleware/auth";

const router = Router();

/**
 * @openapi
 * /api/admin/login:
 *   post:
 *     tags:
 *       - Admin
 *     summary: Admin Login
 *     description: Authenticate an admin and return a JWT token.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               email:
 *                 type: string
 *                 example: admin@college.com
 *               password:
 *                 type: string
 *                 example: admin123
 *     responses:
 *       200:
 *         description: Login successful
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 token:
 *                   type: string
 *                 admin:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: string
 *                     email:
 *                       type: string
 *       400:
 *         description: Invalid credentials
 *       500:
 *         description: Server error
 */
router.post("/login", loginAdmin);

/**
 * @openapi
 * /api/admin/profile:
 *   get:
 *     tags:
 *       - Admin
 *     summary: Get Admin Profile
 *     description: Retrieve the profile data of the currently authenticated admin.
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Profile retrieved successfully
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden (Admin only)
 *       404:
 *         description: Admin not found
 */
router.get("/profile", auth, adminOnly, getAdminProfile);

/**
 * @openapi
 * /api/admin/stats:
 *   get:
 *     tags:
 *       - Admin
 *     summary: Get Dashboard Stats
 *     description: Retrieve various statistics (counts, activities) for the admin dashboard.
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Stats retrieved successfully
 */
router.get("/stats", auth, adminOnly, getDashboardStats);

export default router;