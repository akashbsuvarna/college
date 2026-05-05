import jwt from "jsonwebtoken";

export interface DecodedToken {
  id: string;
  role: string;
}

export const verifyAuth = (req: Request): DecodedToken | null => {
  const authHeader = req.headers.get("authorization");
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return null;
  }

  const token = authHeader.split(" ")[1];
  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || "default_secret"
    ) as DecodedToken;
    return decoded;
  } catch (error) {
    return null;
  }
};
