import express from "express";
import cors from "cors";
import adminRoutes from "./routes/adminAuth";
import studentRoutes from "./routes/studentRoutes";
import teacherRoutes from "./routes/teacherRoutes";
import swaggerUi from "swagger-ui-express";
import swaggerSpec from "./config/swagger";

const app = express();

app.use(cors());
app.use(express.json());

// Swagger Documentation
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.use("/api/admin", adminRoutes);
app.use("/api/admin/teachers", teacherRoutes);
app.use("/api/admin/students", studentRoutes);

export default app;