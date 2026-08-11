const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");

const notFoundMiddleware =
    require("./middleware/notfound_middleware");

const errorMiddleware =
    require("./middleware/error_middleware");


const authRoutes =
    require("./modules/auth/auth_route");

const questionRoutes =
    require("./modules/question/question_router");

const quizRoutes =
    require("./modules/quiz/quiz_route");

const resultRoutes =
    require("./modules/result/result_route");


const app = express();


// Security
app.use(helmet());


// CORS
app.use(
    cors({
        origin:
            process.env.CLIENT_URL ||
            "http://localhost:5173"
    })
);


// Logging
app.use(morgan("common"));


// Body parser
app.use(
    express.json({
        limit: "1mb"
    })
);

app.get("/", (req, res) => {
    res.status(200).json({
        success: true,
        message: "Backend is running"
    });
});


// Routes
app.use(
    "/api/auth",
    authRoutes
);

app.use(
    "/api/questions",
    questionRoutes
);

app.use(
    "/api/quizzes",
    quizRoutes
);

app.use(
    "/api",
    resultRoutes
);


// 404
app.use(notFoundMiddleware);


// Error handler
app.use(errorMiddleware);


module.exports = app;