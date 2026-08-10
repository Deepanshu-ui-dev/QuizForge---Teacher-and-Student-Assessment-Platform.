require("dotenv").config();

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");

const authRoutes = require("./modules/auth/auth_route");
const errorHandler = require("./middleware/error_middleware");
const quizRoutes = require("./modules/quiz/quiz_route");



const app = express();

/* ---------- Global Middlewares ---------- */
app.use(cors());
app.use(helmet());
app.use(morgan("dev"));
app.use(express.json());

/* ---------- Health Check ---------- */
app.get("/", (req, res) => {
    res.status(200).json({
        success: true,
        message: "Quiz Microservices API is running 🚀"
    });
});

/* ---------- Routes ---------- */
app.use("/api/auth", authRoutes);
app.use("/api/quizzes", quizRoutes);

app.use(errorHandler);

module.exports = app;