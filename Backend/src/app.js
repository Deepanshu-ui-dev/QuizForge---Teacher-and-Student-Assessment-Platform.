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


app.use(
    helmet({
        crossOriginResourcePolicy: { policy: "cross-origin" }
    })
);


app.use(
    cors({
        origin: (origin, callback) => {
            if (!origin) return callback(null, true);
            return callback(null, true);
        },
        credentials: true
    })
);


app.use(morgan("common"));

app.use((req, res, next) => {
    const contentType = req.headers["content-type"] || "";
    const contentLength = Number(req.headers["content-length"] || 0);
    if (contentType.includes("application/json") && contentLength === 0) {
        req.body = {};
        return next();
    }
    next();
});

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

app.get("/health", (req, res) => {
    res.status(200).json({
        success: true,
        message: "Quiz Platform API is healthy"
    });
});


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


app.use(notFoundMiddleware);

app.use(errorMiddleware);


module.exports = app;