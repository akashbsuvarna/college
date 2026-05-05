import swaggerJsdoc from "swagger-jsdoc";

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "College Project API",
      version: "1.0.0",
      description: "The admin login system is implemented using secure authentication and role-based authorization with JSON Web Token (JWT). When a user attempts to log in, the system verifies the email, checks whether the user has an admin role, and compares the entered password with the stored hashed password. If the credentials are valid, a JWT is generated containing the user’s identity and role information and is sent to the client. The client stores this token in local storage and includes it in the authorization header for subsequent API requests. Middleware is used on the server to intercept incoming requests, verify the JWT, and ensure that the user has admin privileges before granting access to protected routes. This ensures that only authenticated administrators can access sensitive functionalities, providing a secure, scalable, and stateless authentication mechanism.",
    },
    servers: [
      {
        url: "http://localhost:5000",
        description: "Development server",
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT",
        },
      },
    },
    security: [
      {
        bearerAuth: [],
      },
    ],
  },
  apis: ["./app/routes/*.ts", "./app/controllers/*.ts"], // Paths to files containing OpenAPI definitions
};

const swaggerSpec = swaggerJsdoc(options);

export default swaggerSpec;
